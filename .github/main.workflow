workflow "Run calculation" {
  on = "push"
  resolves = [
    "Simple Addition",
    "new-action",
  ]
}

action "new-action" {
  uses = "owner/repo/path@ref"
}
