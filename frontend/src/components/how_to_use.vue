<template>
  <div class="how_to_use">

    <div class="header">
      <div class="small-title">
        <div class="welcome-border"></div>
        <span class="welcome-text">Welcome to</span>
        <div class="welcome-border"></div>
      </div>

      <div class="title">
        LCS Tracking
      </div>

      <div class="small-title">
        <div class="welcome-border"></div>
      </div>
    </div>

    <div class="">
      <div>
        Select a matchup to view historical stats and compare teams.
      </div>

      <hr>

      <div>
        Mouse over an upcoming game's market to see the approximate <a target="_blank" href="/expected_value.html">Expected Value (EV). </a>
      </div> 
      <img src="/how_to_2.png">
      Select a matchup on the right.
    </div>

    <div>
      View historical stats and compare teams.
    </div>

    <hr>
  </div>
</template>

<script lang="ts">
export default {
  name: 'HowToUse',

  methods: {
    toggle() {
      this.$emit('toggle')
    }
  }
}
</script>

<style lang="scss" scoped>
.how_to_use {
  box-sizing: border-box;
  padding: 8px;
  border-right: 1px solid silver;
  line-height: 150%;
}

.header {
  margin: 0 0 20px 0;
}

.small-title {
  display: flex;
  align-items: center;

  .welcome-border {
    content: "";
    border: 1px solid black;
    flex-grow: 1;
    height: 0px;
  }

  .welcome-text {
    padding: 4px;
  }
}

.title {
  text-align: center;
  padding: 4px 0 8px 0;
  font-size: 2em;
}

img { 
  width: 100% !important; 
  margin: 8px 0;
}

.link {
  text-decoration: underline;
  cursor: pointer;
}

.explanation {
  margin-top: 14px;
  font-size: 1.1em;
}
</style>
