import { createRouter, createWebHistory } from "vue-router";
import DashboardPage from "../pages/DashboardPage.vue";
import LoginPage from "../pages/LoginPage.vue";
import SectionPage from "../pages/SectionPage.vue";

const section = (title: string, description: string) => ({
  component: SectionPage,
  props: { title, description }
});

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", name: "dashboard", component: DashboardPage },
    { path: "/login", name: "login", component: LoginPage },
    { path: "/schools", name: "schools", ...section("Школы и классы", "Структура школы, учебные годы и классы.") },
    { path: "/students", name: "students", ...section("Ученики", "Список учеников и связи с семьями.") },
    { path: "/families", name: "families", ...section("Семьи", "Родители, контакты и приватные комментарии комитета.") },
    { path: "/campaigns", name: "campaigns", ...section("Сборы", "Активные сборы, участники и начисления.") },
    { path: "/payments", name: "payments", ...section("Платежи", "Поступления, подтверждения и остаток к оплате.") },
    { path: "/expenses", name: "expenses", ...section("Расходы", "Расходы, категории и прикрепленные чеки.") },
    { path: "/reports", name: "reports", ...section("Отчеты", "PDF/XLSX отчеты по сборам и классу.") },
    { path: "/notifications", name: "notifications", ...section("Уведомления", "Системные и Telegram-уведомления.") },
    { path: "/telegram", name: "telegram", ...section("Telegram", "Настройки бота, привязка аккаунтов и SOCKS5 proxy.") },
    { path: "/backups", name: "backups", ...section("Резервные копии", "Статус backup и инструкции восстановления.") },
    { path: "/audit", name: "audit", ...section("Журнал действий", "Кто, когда и что изменил в системе.") }
  ]
});
