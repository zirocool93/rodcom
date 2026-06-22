<template>
  <section>
    <div class="page-header">
      <p class="eyebrow">MVP-скелет</p>
      <h1>Панель родительского комитета</h1>
      <p>Базовая оболочка для учета сборов, подтверждений платежей, расходов, отчетов и уведомлений.</p>
    </div>

    <div class="metrics">
      <article v-for="metric in metrics" :key="metric.label" class="metric-card">
        <span>{{ metric.label }}</span>
        <strong>{{ metric.value }}</strong>
      </article>
    </div>

    <section class="work-chain">
      <h2>Цепочка MVP</h2>
      <p>Класс -> Семьи -> Сбор -> Начисления -> Платеж -> Подтверждение -> Расход -> Баланс -> Отчет -> Telegram -> Backup.</p>
    </section>
  </section>
</template>

<script setup lang="ts">
const metrics = [
  { label: "Активные сборы", value: "0" },
  { label: "Ожидается оплата", value: "0 ₽" },
  { label: "Подтверждено", value: "0 ₽" },
  { label: "Новые уведомления", value: "0" }
];
</script>
