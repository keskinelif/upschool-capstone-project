from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api import routes_admin, routes_auth, routes_contributions, routes_map, routes_system, routes_tags, routes_venues
from app.core.settings import settings
from app.db.memory_store import seed_data


@asynccontextmanager
async def lifespan(_: FastAPI):
    seed_data()
    yield


app = FastAPI(title=settings.app_name, lifespan=lifespan)

app.include_router(routes_system.router)
app.include_router(routes_auth.router)
app.include_router(routes_tags.router)
app.include_router(routes_venues.router)
app.include_router(routes_map.router)
app.include_router(routes_contributions.router)
app.include_router(routes_admin.router)
