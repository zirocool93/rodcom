from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError


class Command(BaseCommand):
    help = "Создает или обновляет первоначального администратора RodCom."

    def add_arguments(self, parser):
        parser.add_argument("--login", required=True, help="Логин администратора.")
        parser.add_argument("--password", required=True, help="Пароль администратора.")
        parser.add_argument("--email", default="", help="Email администратора, если отличается от логина.")

    def handle(self, *args, **options):
        login = options["login"].strip()
        password = options["password"]
        email = options["email"].strip()

        if not login:
            raise CommandError("Логин администратора не может быть пустым.")

        if len(password) < 8:
            raise CommandError("Пароль администратора должен быть не короче 8 символов.")

        User = get_user_model()
        username_field = User.USERNAME_FIELD
        lookup = {username_field: login}

        user, created = User.objects.get_or_create(
            **lookup,
            defaults={
                "email": email or (login if "@" in login else ""),
                "is_staff": True,
                "is_superuser": True,
                "is_active": True,
            },
        )

        user.is_staff = True
        user.is_superuser = True
        user.is_active = True
        if hasattr(user, "email") and (email or "@" in login):
            user.email = email or login
        user.set_password(password)
        user.save()

        action = "создан" if created else "обновлен"
        self.stdout.write(self.style.SUCCESS(f"Администратор '{login}' {action}."))
