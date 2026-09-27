[⬆ Examples](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)

# Meta-argument labs

🟡 Intermediate · Companion labs for [Chapter 09 · Meta-arguments](../../docs/09-meta-arguments/README.md)

Do them in this order. Each is independent: `init`, `apply`, experiment, `destroy`.

| # | Lab | Meta-argument | 💰 Cost while running |
| --- | --- | --- | --- |
| 1 | [count-and-for-each](count-and-for-each/README.md) | `count`, `for_each`, chained `for_each` | 2 × `t3.micro` + 3 empty buckets |
| 2 | [count-vs-for-each](count-vs-for-each/README.md) | why keys beat indexes | Free (idle SQS queues) |
| 3 | [depends-on](depends-on/README.md) | hidden dependencies | 1 × `t3.micro` |
| 4 | [multi-region-providers](multi-region-providers/README.md) | `provider`, `providers`, aliases | Free (empty buckets) |
| 5 | [lifecycle](lifecycle/README.md) | `create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`, `precondition` | 1 × `t3.micro` |

---

[⬆ Examples](../README.md) | [🏠 Home](../../README.md) | [📚 Learning Path](../../docs/00-learning-roadmap/README.md)
