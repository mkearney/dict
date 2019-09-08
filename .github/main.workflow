workflow "Run calculation" {
  resolves = [
    "Simple Addition",
  ]
  on = "push"
}
