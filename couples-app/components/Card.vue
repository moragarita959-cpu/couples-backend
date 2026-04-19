<template>
  <div class="card" :class="customClass">
    <slot></slot>
  </div>
</template>

<script>
export default {
  props: {
    customClass: {
      type: String,
      default: ''
    }
  }
}
</script>

<style scoped>
.card {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin: 20px 0;
}
</style>