<template>
  <section>
    <div class="page-header">
      <p class="eyebrow">Раздел MVP</p>
      <h1>{{ title }}</h1>
      <p>{{ description }}</p>
    </div>
    <div class="empty-state">
      <strong>Раздел готов к подключению API.</strong>
      <span>На следующем этапе здесь появятся таблицы, формы и действия по ролям.</span>
    </div>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  description: string;
}>();
</script>
