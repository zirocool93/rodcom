<template>
  <div class="app-shell">
    <aside class="sidebar">
      <RouterLink class="brand" to="/">
        <span class="brand-mark">R</span>
        <span>
          <strong>RodCom</strong>
          <small>Родительский комитет</small>
        </span>
      </RouterLink>
      <nav class="nav">
        <RouterLink v-for="item in items" :key="item.to" :to="item.to">{{ item.label }}</RouterLink>
      </nav>
    </aside>
    <main class="content">
      <RouterView />
    </main>
  </div>
</template>

<script setup lang="ts">
const items = [
  { to: "/", label: "Панель" },
  { to: "/schools", label: "Школы" },
  { to: "/students", label: "Ученики" },
  { to: "/families", label: "Семьи" },
  { to: "/campaigns", label: "Сборы" },
  { to: "/payments", label: "Платежи" },
  { to: "/expenses", label: "Расходы" },
  { to: "/reports", label: "Отчеты" },
  { to: "/telegram", label: "Telegram" },
  { to: "/backups", label: "Backup" },
  { to: "/audit", label: "Журнал" }
];
</script>
