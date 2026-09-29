## launch with 'uvicorn api_dev:app --reload'

from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

class Applet(BaseModel):
    title: str
    description: str
    color: str
    icon: List[str]
    tags: List[str]
    author: str
    nb_of_users: int = 0
    is_enabled: bool

class Action(BaseModel):
    title: str
    description: str
    color: str
    icon: str
    tags: List[str]
    ingredients: List[str]

app = FastAPI()

@app.get("/applet", response_model=Applet)
def get_applet():
    return Applet(
        title="Youtube",
        description="publish the video of reno",
        color="#FF5733",
        icon=["assets/Logo_Youtube.svg"],
        tags=["sample", "applet", "ifttt"],
        author="Reno",
        nb_of_users=230,
        is_enabled=True
    )

@app.get("/actions", response_model=List[Action])
def get_action():
    return [
        Action(
        title="Youtube",
        description="publish the video of reno",
        color="#FF5733",
        icon="assets/Logo_Youtube.svg",
        tags=["sample", "applet", "ifttt"],
        ingredients=["video", "title", "description"],
        ),
    ]

@app.get("/reactions", response_model=List[Action])
def get_reaction():
    return [
        Action(
            title="Youtube",
            description="Youtube allows you to publish the video scrap content and publish it on youtube with a custom title and description to make it more appealing to your audience and get more views and subscribers",
            color="#FF5733",
            icon="assets/Logo_Youtube.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Telegram",
            description="send a message to reno",
            color="#0088cc",
            icon="assets/Logo_Telegram.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Discord",
            description="send a message to reno",
            color="#7289DA",
            icon="assets/Logo_Discord.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Xbox",
            description="send a message to reno",
            color="#107C10",
            icon="assets/Logo_Xbox.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Blender",
            description="send a message to reno",
            color="#f5792a",
            icon="assets/Logo_Blender.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Steam",
            description="send a message to reno",
            color="#003A5F",
            icon="assets/Logo_Steam.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Github",
            description="send a message to reno",
            color="#000000",
            icon="assets/Logo_Github.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Dropbox",
            description="send a message to reno",
            color="#007EE5",
            icon="assets/Logo_Dropbox.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="AWS",
            description="send a message to reno",
            color="#FF9900",
            icon="assets/Logo_Aws.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Airbnb",
            description="send a message to reno",
            color="#FF5A5F",
            icon="assets/Logo_Airbnb.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Dazn",
            description="send a message to reno",
            color="#FF0000",
            icon="assets/Logo_Dazn.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        ),
        Action(
            title="Bose",
            description="send a message to reno",
            color="#000000",
            icon="assets/Logo_Bose.svg",
            tags=["sample", "applet", "ifttt"],
            ingredients=["video", "title", "description"]
        )
    ]


@app.get("/applets", response_model=List[Applet])
def get_applets():
    return [
        Applet(
            title="Youtube",
            description="Send a short when reno",
            color="#ff0000",
            icon=["assets/Logo_Youtube.svg", "assets/Logo_Dropbox.svg","assets/Logo_Telegram.svg"],
            tags=["Sample", "Applet", "Ifttt"],
            author="Reno",
            nb_of_users=87,
            is_enabled=True
        ),
        Applet(
            title="Github",
            description="Repo mirroring automation with github actions and webhooks for a better workflow experience and a better code quality",
            color="#000000",
            icon=["assets/Logo_Github.svg"],
            tags=["Example", "Applet", "Automation","Webhook","Github","Actions"],
            author="Reno",
            nb_of_users=12,
            is_enabled=False
        ),
        Applet(
            title="Xbox",
            description="Send a message to your friends when you are online on xbox live with a custom message and a custom emoji to make them laugh",
            color="#1D801C",
            icon=["assets/Logo_Xbox.svg"],
            tags=["Sample", "Applet", "Ifttt"],
            author="Reno",
            nb_of_users=45,
            is_enabled=True
        ),
        Applet(
            title="Steam",
            description="Steam game recommendation based on your library also show you the best deals on the store for the games you want",
            color="#003A5F",
            icon=["assets/Logo_Steam.svg"],
            tags=["Example", "Applet", "Automation"],
            author="Reno",
            nb_of_users=320,
            is_enabled=False
        )
    ]