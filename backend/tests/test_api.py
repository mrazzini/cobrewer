BEAN_PAYLOAD = {
    "name": "Chelbesa Lot 5",
    "roaster": "The Barn",
    "origin": "Ethiopia, Yirgacheffe",
    "variety": "Heirloom",
    "process": "washed",
    "roast_level": "light",
    "tasting_notes": ["jasmine", "peach"],
    "cupping_score": 88.25,
}

DEV = {"X-Dev-User": "tester"}


async def test_health(client):
    resp = await client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


async def test_create_and_get_bean(client):
    resp = await client.post("/api/v1/beans", json=BEAN_PAYLOAD, headers=DEV)
    assert resp.status_code == 201, resp.text
    body = resp.json()
    assert body["error"] is None
    bean = body["data"]
    assert bean["name"] == "Chelbesa Lot 5"
    assert bean["is_verified"] is False

    resp = await client.get(f"/api/v1/beans/{bean['id']}")
    assert resp.status_code == 200
    assert resp.json()["data"]["tasting_notes"] == ["jasmine", "peach"]


async def test_get_missing_bean_is_enveloped_404(client):
    resp = await client.get("/api/v1/beans/00000000-0000-0000-0000-000000000000")
    assert resp.status_code == 404
    body = resp.json()
    assert body["data"] is None
    assert body["error"] == "Bean not found"


async def test_bean_filters_and_search(client):
    await client.post("/api/v1/beans", json=BEAN_PAYLOAD, headers=DEV)
    await client.post(
        "/api/v1/beans",
        json={
            **BEAN_PAYLOAD,
            "name": "Cerrado Nut Bomb",
            "origin": "Brazil, Cerrado",
            "process": "natural",
            "roast_level": "dark",
        },
        headers=DEV,
    )

    resp = await client.get("/api/v1/beans", params={"origin": "ethiopia"})
    data = resp.json()["data"]
    assert len(data) == 1 and data[0]["origin"].startswith("Ethiopia")

    resp = await client.get("/api/v1/beans", params={"process": "NATURAL"})
    assert len(resp.json()["data"]) == 1

    resp = await client.get("/api/v1/beans", params={"search": "chelbesa"})
    assert len(resp.json()["data"]) == 1

    resp = await client.get("/api/v1/beans")
    assert resp.json()["meta"]["total"] == 2


async def test_unauthenticated_write_rejected_outside_debug(client, monkeypatch):
    from app.config import settings

    monkeypatch.setattr(settings, "DEBUG", False)
    resp = await client.post("/api/v1/beans", json=BEAN_PAYLOAD)
    assert resp.status_code == 401
    assert resp.json()["error"] == "Not authenticated"

    # Reads stay public.
    resp = await client.get("/api/v1/beans")
    assert resp.status_code == 200


async def test_recommendation_flow(client):
    bean = (await client.post("/api/v1/beans", json=BEAN_PAYLOAD, headers=DEV)).json()["data"]

    resp = await client.get(
        "/api/v1/recommendations",
        params={"bean_id": bean["id"], "brewer": "v60", "grinder": "comandante_c40"},
    )
    assert resp.status_code == 200, resp.text
    rec = resp.json()["data"]
    assert rec["generated_by"] == "rules"
    params = rec["parameters"]
    # light + washed on v60: 24 - 2 = 22 clicks, temp 93 + 2.5 = 95.5
    assert params["grind_setting_c40_clicks"] == 22
    assert params["water_temp_c"] == 95.5
    assert params["grind_setting"]["converted"] is True


async def test_recommendation_unsupported_brewer(client):
    bean = (await client.post("/api/v1/beans", json=BEAN_PAYLOAD, headers=DEV)).json()["data"]
    resp = await client.get(
        "/api/v1/recommendations", params={"bean_id": bean["id"], "brewer": "moka_pot"}
    )
    assert resp.status_code == 422
    assert "Unsupported brewer" in resp.json()["error"]


async def test_brew_log_flow(client):
    bean = (await client.post("/api/v1/beans", json=BEAN_PAYLOAD, headers=DEV)).json()["data"]

    brew = {
        "bean_id": bean["id"],
        "brewer": "v60",
        "grinder": "comandante_c40",
        "grind_setting": 22,
        "dose_g": 15.0,
        "yield_g": 240.0,
        "water_temp_c": 95.5,
        "brew_time_seconds": 195,
        "rating": 4,
        "notes": "Sweet, slightly astringent finish",
        "generated_by": "rules",
    }
    resp = await client.post("/api/v1/brews", json=brew, headers=DEV)
    assert resp.status_code == 201, resp.text

    resp = await client.get("/api/v1/brews", headers=DEV)
    logs = resp.json()["data"]
    assert len(logs) == 1
    assert logs[0]["rating"] == 4

    # Another user sees their own (empty) history, not the tester's.
    resp = await client.get("/api/v1/brews", headers={"X-Dev-User": "someone_else"})
    assert resp.json()["data"] == []


async def test_brew_rating_validation(client):
    bean = (await client.post("/api/v1/beans", json=BEAN_PAYLOAD, headers=DEV)).json()["data"]
    resp = await client.post(
        "/api/v1/brews", json={"bean_id": bean["id"], "brewer": "v60", "rating": 6}, headers=DEV
    )
    assert resp.status_code == 422
    assert resp.json()["error"] == "Validation error"


async def test_users_me_and_equipment(client):
    resp = await client.get("/api/v1/users/me", headers=DEV)
    assert resp.status_code == 200
    me = resp.json()["data"]
    assert me["clerk_id"] == "dev_tester"
    assert me["ai_credits"] == {"extractions_used": 0, "extractions_limit": 3}
    assert me["equipment"] == []

    resp = await client.put(
        "/api/v1/users/me/equipment",
        json={
            "equipment": [
                {
                    "equipment_type": "grinder",
                    "brand": "Comandante",
                    "model": "C40",
                    "burr_type": "conical",
                },
                {"equipment_type": "brewer", "brand": "Hario", "model": "V60-02"},
            ]
        },
        headers=DEV,
    )
    assert resp.status_code == 200
    assert len(resp.json()["data"]["equipment"]) == 2

    # Full replace, not append.
    resp = await client.put(
        "/api/v1/users/me/equipment",
        json={"equipment": [{"equipment_type": "grinder", "brand": "Fellow", "model": "Ode"}]},
        headers=DEV,
    )
    assert len(resp.json()["data"]["equipment"]) == 1


async def test_extract_unconfigured_returns_503(client):
    files = {"file": ("bag.jpg", b"\xff\xd8\xff fake-jpeg", "image/jpeg")}
    resp = await client.post("/api/v1/extract/bag-photo", files=files, headers=DEV)
    assert resp.status_code == 503
    assert "not configured" in resp.json()["error"]


async def test_extract_rejects_non_image(client):
    files = {"file": ("bag.txt", b"hello", "text/plain")}
    resp = await client.post("/api/v1/extract/bag-photo", files=files, headers=DEV)
    assert resp.status_code == 415
