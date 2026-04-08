import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import os
from collections import deque

# Константы модели
k_ob, T_ob1, T_ob2, tau = 1.0, 1.0, 3.0, 0.3
dt, T_max = 0.01, 20.0
steps = int(T_max / dt)
delay_steps = int(tau / dt)

t = np.linspace(0, T_max, steps)
g = np.ones(steps)

def simulate_pid(q1, q2, q3):
    y = np.zeros(steps)
    y_delayed = np.zeros(steps)
    z = 0.0
    integral = 0.0
    prev_error = 0.0
    y_buffer = deque(maxlen=delay_steps + 1)

    for n in range(steps):
        y_now = y[n]
        error = g[n] - y_now
        integral_new = integral + error * dt
        derivative = (error - prev_error) / dt if dt > 0 else 0
        u = np.clip(q1 * error + q2 * integral_new + q3 * derivative, -10, 10)

        y_buffer.append(y_now)
        if len(y_buffer) > delay_steps:
            y_delayed[n] = y_buffer.popleft()
        else:
            y_delayed[n] = 0.0

        if n < steps - 1:
            z_new = (k_ob * u - z) / T_ob2 * dt + z
            y[n + 1] = (T_ob1 / T_ob2) * k_ob * u + (1 - T_ob1 / T_ob2) * z_new
            z = z_new

        integral, prev_error = integral_new, error

    I_no_delay = np.sum((g - y) ** 2) * dt
    I_delay = np.sum((g - y_delayed) ** 2) * dt
    return y, y_delayed, I_no_delay, I_delay

def optimize_coordinate(q_fixed, fixed_params, coord):
    a, b = 0.0, 5000.0
    n_points = 1000
    best_q = q_fixed
    best_I = float('inf')

    for i in range(n_points + 1):
        q_test = a + (b - a) * i / n_points
        test_params = list(fixed_params)
        test_params[coord] = q_test
        _, _, I_no_delay, _ = simulate_pid(*test_params)
        if I_no_delay < best_I:
            best_I = I_no_delay
            best_q = q_test
            
    return best_q

# Начальные параметры
q1_init, q2_init, q3_init = 1.0, 0.0, 0.0
max_iterations = 10
tolerance = 0.001

q_current = [q1_init, q2_init, q3_init]
_, _, I_current, _ = simulate_pid(*q_current)

print(f"Начальные параметры: q1={q_current[0]:.3f}, q2={q_current[1]:.3f}, q3={q_current[2]:.3f}")
print(f"Начальный критерий: I = {I_current:.4f}")
print()

for iteration in range(max_iterations):
    I_prev = I_current

    for coord in range(3):
        q_current[coord] = optimize_coordinate(q_current[coord], tuple(q_current), coord)

    _, _, I_current, _ = simulate_pid(*q_current)
    print(f"Итерация {iteration + 1}: q1={q_current[0]:.3f}, q2={q_current[1]:.3f}, q3={q_current[2]:.3f}, I={I_current:.4f}")

    if abs(I_prev - I_current) < tolerance:
        print(f"\nСходимость достигнута на итерации {iteration + 1}")
        break

q1_opt, q2_opt, q3_opt = q_current
I_opt = I_current

print()
print("=" * 50)
print(f"Оптимальные параметры: q1*={q1_opt:.3f}, q2*={q2_opt:.3f}, q3*={q3_opt:.3f}")
print(f"Оптимальный критерий: I* = {I_opt:.4f}")

# Финальное моделирование с оптимальными параметрами
y_opt, y_opt_delayed, I_no_delay, I_delay = simulate_pid(q1_opt, q2_opt, q3_opt)
y_init, y_init_delayed, I_init, _ = simulate_pid(q1_init, q2_init, q3_init)

print(f"\nНачальный критерий: I0 = {I_init:.4f}")
print(f"Оптимальный критерий: I* = {I_opt:.4f}")
print(f"Улучшение: {(I_init / I_opt):.2f} раз")

# Построение графика
plt.figure(figsize=(10, 6))
plt.plot(t, y_init, "-b", label=f"Начальный (q1={q1_init})", linewidth=2)
plt.plot(t, y_init_delayed, "--g", label="Начальный с запаздыванием", linewidth=1.5)
plt.plot(t, y_opt, "-r", label=f"Оптимальный (q1*={q1_opt:.2f}, q2*={q2_opt:.2f}, q3*={q3_opt:.2f})", linewidth=2)
plt.plot(t, y_opt_delayed, "--m", label="Оптимальный с запаздыванием", linewidth=1.5)
plt.step(t, g, "-k", label="g(t) - уставка", where='post', linewidth=1.5)

plt.grid(True, linestyle=':')
plt.legend(loc='lower right')
plt.xlabel("Время, с")
plt.ylabel("Выход y(t)")
plt.title(f"Метод покоординатного спуска\nI₀={I_init:.4f}, I*={I_opt:.4f}")
plt.tight_layout()

# Сохранение графика
script_dir = os.path.dirname(os.path.abspath(__file__))
images_dir = os.path.join(script_dir, 'images')
os.makedirs(images_dir, exist_ok=True)
output_path = os.path.join(images_dir, "task5_покоординатный_спуск.png")
plt.savefig(output_path, dpi=150, bbox_inches='tight')
plt.close()
print(f"\nГрафик сохранен: {output_path}")