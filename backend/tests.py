from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def find_id(endpoint: str, title: str) -> str:
    return next(item["id"] for item in client.get(endpoint).json() if item["title"] == title)

def any_service_id() -> str:
    return client.get("/services").json()[0]["id"]

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_user_crud():
    new_user = {
        "name": "Adrien",
        "surname": "Lamenace",
        "email": "adridri@epitech.eu",
        "password": "password123",
        "birthdate": "1990-01-01",
        "gender": "male"
    }
    create_response = client.post("/users", json=new_user)
    assert create_response.status_code == 200, f"Unexpected status code: {create_response.status_code}"
    login_data = {
        "username": "adridri@epitech.eu",
        "password": "password123"
    }
    login_response = client.post("/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Unexpected status code: {login_response.status_code}"
    json_response = login_response.json()
    assert "access_token" in json_response, "Access token not found in response"
    assert json_response["token_type"] == "bearer"
    access_token = json_response["access_token"]
    headers = {"Authorization": f"Bearer {access_token}"}
    updated_user_data = {
        "name": "Adrien Updated",
        "surname": "Lamenace Updated",
        "email": "updated_email@epitech.eu",
    }
    patch_response = client.patch("/users/me", json=updated_user_data, headers=headers)
    assert patch_response.status_code == 200, f"Unexpected status code: {patch_response.status_code}"
    updated_user = patch_response.json()
    assert updated_user["name"] == updated_user_data["name"], "User name not updated"
    assert updated_user["surname"] == updated_user_data["surname"], "User surname not updated"
    assert updated_user["email"] == updated_user_data["email"], "User email not updated"
    delete_response = client.delete("/users/me", headers=headers)
    assert delete_response.status_code == 200, f"Unexpected status code: {delete_response.status_code}"

def test_service_crud():
    auth_data = {
        "username": "admin",
        "password": "admin"
    }
    response = client.post("/auth/login", data=auth_data)
    assert response.status_code == 200
    admin_token = response.json()["access_token"]
    response = client.get("/services")
    assert response.status_code == 200
    service_data = {
        "name": "Test Service",
        "color": "#FF0000"
    }
    headers = {"Authorization": f"Bearer {admin_token}"}
    response = client.post("/services", json=service_data, headers=headers)
    assert response.status_code == 200
    created_service = response.json()
    assert created_service["name"] == service_data["name"]
    assert created_service["color"] == service_data["color"]
    service_id = created_service["id"]
    response = client.get(f"/services/{service_id}")
    assert response.status_code == 200
    service_info = response.json()
    assert service_info["id"] == service_id
    assert service_info["name"] == service_data["name"]
    assert service_info["color"] == service_data["color"]
    updated_service_data = {
        "name": "Updated Test Service",
        "color": "#00FF00"
    }
    response = client.patch(f"/services/{service_id}", json=updated_service_data, headers=headers)
    assert response.status_code == 200
    updated_service = response.json()
    assert updated_service["name"] == updated_service_data["name"]
    assert updated_service["color"] == updated_service_data["color"]
    response = client.delete(f"/services/{service_id}", headers=headers)
    assert response.status_code == 200
    assert response.json() == {"message": "Service deleted successfully"}
    response = client.get(f"/services/{service_id}")
    assert response.status_code == 404

def test_action_crud():
    auth_data = {
        "username": "admin",
        "password": "admin"
    }
    response = client.post("/auth/login", data=auth_data)
    assert response.status_code == 200
    admin_token = response.json()["access_token"]
    response = client.get(f"/services/{any_service_id()}/actions")
    assert response.status_code == 200
    action_data = {
        "title": "Test Action",
        "description": "This is a test action",
        "input_fields": [{"name": "input1", "regex": ".*", "example": "example"}],
        "output_fields": ["output1"],
        "route": "/test/action",
        "provider": None,
        "polling_interval": 10,
        "webhook": False
    }
    headers = {"Authorization": f"Bearer {admin_token}"}
    response = client.post(f"/services/{any_service_id()}/actions", json=action_data, headers=headers)
    assert response.status_code == 200
    created_action = response.json()
    assert created_action["title"] == action_data["title"]
    action_id = created_action["id"]
    response = client.get(f"/actions/{action_id}")
    assert response.status_code == 200
    action_info = response.json()
    assert action_info["id"] == action_id
    assert action_info["title"] == action_data["title"]
    response = client.delete(f"/actions/{action_id}", headers=headers)
    assert response.status_code == 200
    assert response.json() == {"message": "Action deleted successfully"}
    response = client.get(f"/actions/{action_id}")
    assert response.status_code == 404

def test_reaction_crud():
    auth_data = {
        "username": "admin",
        "password": "admin"
    }
    response = client.post("/auth/login", data=auth_data)
    assert response.status_code == 200
    admin_token = response.json()["access_token"]
    response = client.get(f"/services/{any_service_id()}/reactions")
    assert response.status_code == 200
    reaction_data = {
        "title": "Test Reaction",
        "description": "This is a test reaction",
        "input_fields": [{"name": "input1", "regex": ".*", "example": "example"}],
        "route": "/test/reaction",
        "provider": None
    }
    headers = {"Authorization": f"Bearer {admin_token}"}
    response = client.post(f"/services/{any_service_id()}/reactions", json=reaction_data, headers=headers)
    assert response.status_code == 200
    created_reaction = response.json()
    assert created_reaction["title"] == reaction_data["title"]
    reaction_id = created_reaction["id"]
    response = client.get(f"/reactions/{reaction_id}")
    assert response.status_code == 200
    reaction_info = response.json()
    assert reaction_info["id"] == reaction_id
    assert reaction_info["title"] == reaction_data["title"]
    response = client.delete(f"/reactions/{reaction_id}", headers=headers)
    assert response.status_code == 200
    assert response.json() == {"message": "Reaction deleted successfully"}
    response = client.get(f"/reactions/{reaction_id}")
    assert response.status_code == 404

def test_applets():
    auth_data = {
        "username": "admin",
        "password": "admin"
    }
    response = client.post("/auth/login", data=auth_data)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    admin_token = response.json()["access_token"]
    applet_data = {
        "title": "Test Applet",
        "description": "This is a test applet",
        "tags": ["test", "applet"],
        "action_id": find_id("/actions", "It is Christmas"),
        "action_inputs": {},
        "reactions": [
            {
                "reaction_id": find_id("/reactions", "Append to file"),
                "reaction_inputs": {"filename": "value1", "content": "value2"}
            }
        ]
    }
    headers = {"Authorization": f"Bearer {admin_token}"}
    response = client.get("/users/me/applets", headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    response = client.post("/users/me/applets", json=applet_data, headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    created_user_applet = response.json()
    updated_applet_data = {
        "title": "Updated Test Applet",
        "description": "This is an updated test applet"
    }
    response = client.patch(f"/users/me/applets/{created_user_applet['id']}", json=updated_applet_data, headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    updated_user_applet = response.json()
    assert updated_user_applet["title"] == updated_applet_data["title"]
    assert updated_user_applet["description"] == updated_applet_data["description"]
    client.delete(f"/users/me/applets/{created_user_applet['id']}", headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    response = client.get("/applets")
    assert response.status_code == 200
    response = client.post("/applets", json=applet_data, headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    created_public_applet = response.json()
    response = client.post(f"/users/me/applets/{created_public_applet['id']}", headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    created_user_applet_from_public = response.json()
    response = client.delete(f"/applets/{created_public_applet['id']}", headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
    response = client.delete(f"/users/me/applets/{created_user_applet_from_public['id']}", headers=headers)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code} - {response.json()}"
