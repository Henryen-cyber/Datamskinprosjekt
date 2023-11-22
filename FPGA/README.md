# RayCore FSM
| Inputs      |     |States         |            |Outputs  |      |
|-------------|-----|---------------|------------|---------|------|
| In0         | In1 | CURRENT_STATE | NEXT_STATE | Out0    | Out1 |
| start       |     | START         | TRACING    |         |      |
| next_sphere |     | TRACING       | TRACING    | busy    |      |
| pixel_done  |     | TRACING       | STARTING   | busy    |      |

# Tracing FSM
| Inputs   |     | States        |             | Outputs     |       |
|----------|-----|---------------|-------------|-------------|-------|
| In0      | In1 | CURRENT_STATE | NEXT_STATE  | Out0        | Out1  |
| valid    |     | IDLE          | CALCULATING | next_sphere | index |
| finished |     | CALCULATING   | IDLE        |             |       |
