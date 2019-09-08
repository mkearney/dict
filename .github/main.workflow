workflow "Run calculation" {
  on = "push"
  resolves = [
    "Simple Addition"
  ]
}

