from aiogram import Router
from aiogram.filters import CommandStart
from aiogram.types import Message

router = Router()


@router.message(CommandStart())
async def start(message: Message) -> None:
    await message.answer(
        "Здравствуйте. Это бот RodCom для уведомлений родительского комитета.\n\n"
        "Привязка аккаунта и отправка подтверждений оплаты будут подключены на следующем этапе."
    )
