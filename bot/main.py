import asyncio
import logging

from aiogram import Bot, Dispatcher

from handlers.start import router as start_router
from services.config import settings
from services.proxy import build_session


async def main() -> None:
    logging.basicConfig(level=logging.INFO)

    if not settings.telegram_bot_token:
        logging.warning("TELEGRAM_BOT_TOKEN не задан, бот не запущен.")
        return

    bot = Bot(token=settings.telegram_bot_token, session=build_session())
    dispatcher = Dispatcher()
    dispatcher.include_router(start_router)

    await dispatcher.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())
