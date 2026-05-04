import numpy as np
import matplotlib.pyplot as plt

def f(X):
    x1, x2 = X
    # Вариант 7
    return -5 * x1 - 2 * x2 + x1**2 - x1 * x2 + x2**2

def h1(X):
    x1, x2 = X
    # Равенство (вариант 7)
    return x1 + 2 * x2 - 8

def g1(X):
    x1, x2 = X
    # Неравенство (вариант 7): 15 - 2x1 - 3x2 >= 0
    return 15 - 2 * x1 - 3 * x2

def g2(X):
    x1, _ = X
    return x1

def g3(X):
    _, x2 = X
    return x2

def P(X, r):
    x1, x2 = X
    f_val = f(X)
    h_val = h1(X)
    g1_val = g1(X)
    g2_val = g2(X)
    g3_val = g3(X)

    penalty_eq = (1.0 / np.sqrt(r)) * h_val ** 2
    penalty_ineq = r * (1.0 / g1_val + 1.0 / g2_val + 1.0 / g3_val)

    return f_val + penalty_eq + penalty_ineq

def gradient_P(X, r):
    x1, x2 = X
    h = x1 + 2 * x2 - 8
    g1_val = 15 - 2 * x1 - 3 * x2
    g2_val = x1
    g3_val = x2

    # ∇f (вариант 7)
    df_dx1 = -5 + 2 * x1 - x2
    df_dx2 = -2 - x1 + 2 * x2

    factor_eq = 2.0 / np.sqrt(r)
    d_eq_dx1 = factor_eq * h
    d_eq_dx2 = 4.0 * factor_eq * h  # производная (x1+2x2-8)^2 по x2

    # Барьер: r*(1/g1 + 1/x1 + 1/x2)
    # d/dx1 (1/g1) = +2/g1^2, d/dx2 (1/g1) = +3/g1^2
    d_ineq_dx1 = r * (2.0 / (g1_val**2) - 1.0 / (g2_val**2))
    d_ineq_dx2 = r * (3.0 / (g1_val**2) - 1.0 / (g3_val**2))

    return np.array([df_dx1 + d_eq_dx1 + d_ineq_dx1,
                     df_dx2 + d_eq_dx2 + d_ineq_dx2])

X = np.array([5.0, 1.0])
r = 10

history_X = []
history_f = []
history_P = []

print(f"Начальная точка: ({X[0]}, {X[1]})")
print(f"f = {f(X)}")
print(f"h2 = x1 + 2x2 - 8 = {h1(X)}")
print(f"g1 = 15 - 2x1 - 3x2 = {g1(X)}")
print(f"P(X, r) = {P(X, r)}")

history_X.append(X.copy())
history_f.append(f(X))
history_P.append(P(X, r))

a = 0
iter_counter = 0

# Поиск шага Вульфа
def line_search_wolfe(X, delta, r, grad, c1=1e-4, c2=0.9, alpha_max=1.0, rho=0.5, max_iter=100):
    alpha = alpha_max
    P_current = P(X, r)
    grad_current = grad

    for _ in range(max_iter):
        X_new = X + alpha * delta
        if P(X_new, r) > P_current + c1 * alpha * grad_current @ delta:
            alpha *= rho
            continue

        grad_new = gradient_P(X_new, r)
        if grad_new @ delta < c2 * grad_current @ delta:
            if alpha < alpha_max:
                alpha = min(alpha_max, alpha * 1.5)
            continue

        return alpha

    return alpha * 0.1

for outer_iter in range(20):
    print(f"\nr = {r}")

    for inner_iter in range(50):
        grad = gradient_P(X, r)
        grad_norm = np.linalg.norm(grad)
        a += 1
        iter_counter += 1

        if grad_norm < 1e-3:
            print(f"  Сошлись за {inner_iter} итераций")
            break

        # Градиентный шаг (нормированный антиградиент)
        delta = -grad / (grad_norm)

        alpha = line_search_wolfe(X, delta, r, grad)

        # Поиск шага Armijo
        # alpha = 1.0
        # P_current = P(X, r)
        # while alpha > 1e-8:
        #     X_new = X + alpha * delta
        #     if P(X_new, r) < P_current + 0.5 * alpha * grad @ delta:
        #         break
        #     alpha *= 0.5

        X = X + alpha * delta

        history_X.append(X.copy())
        history_f.append(f(X))
        history_P.append(P(X, r))

        if inner_iter % 10 == 0:
            print(f"  iter {inner_iter:2d}: X=({X[0]:.4f}, {X[1]:.4f}), ||grad||={grad_norm:.2e}")

    print(f"  X = ({X[0]:.6f}, {X[1]:.6f})")
    print(f"  f = {f(X):.6f}")
    print(f"  h2 = {h1(X):.2e}")
    print(f"  g1 = {g1(X):.2e}")
    print(f"P(X, r) = {P(X, r)}")

    if r < 1e-2 or abs(P(X, r) - f(X)) < 1e-2:
        break

    r = r / 4  # уменьшаем штраф

print("\nИтог")
print(f"X* = ({X[0]:.6f}, {X[1]:.6f})")
print(f"f* = {f(X):.6f}")
print(f"Проверка x1 + 2x2 - 8 = {h1(X):.2e}")
print(f"Теоретический оптимум: ({24.0/7.0:.6f}, {16.0/7.0:.6f}), f = {-88.0/7.0:.6f}")

print(a, "кол-во итераций")

# ГРАФИК: одна поверхность f, на ней траектории для f и P
x1_grid = np.linspace(0, 6, 100)
x2_grid = np.linspace(0, 6, 100)
X1, X2 = np.meshgrid(x1_grid, x2_grid)

Z_f = -5 * X1 - 2 * X2 + X1**2 - X1 * X2 + X2**2

history_X = np.array(history_X)
Z_f_traj = np.array(history_f)
Z_P_traj = np.array(history_P)

fig = plt.figure(figsize=(14, 9))
ax = fig.add_subplot(111, projection='3d')

# Поверхность f(x1, x2)
surf = ax.plot_surface(X1, X2, Z_f, cmap='viridis', alpha=0.7, edgecolor='none')

# Траектория значений f (красная)
ax.plot(history_X[:, 0], history_X[:, 1], Z_f_traj,
        'r-o', linewidth=2, markersize=4, label='Траектория f(X)')

# Траектория значений P (синяя)
ax.plot(history_X[:, 0], history_X[:, 1], Z_P_traj,
        'b-s', linewidth=2, markersize=4, label='Траектория P(X, r)')

# Начальная точка (зеленая)
ax.scatter(history_X[0, 0], history_X[0, 1], Z_f_traj[0],
           color='lime', s=100, edgecolor='black', linewidth=1.5, label='Начальная точка (f)')

# Конечная точка (красная)
ax.scatter(history_X[-1, 0], history_X[-1, 1], Z_f_traj[-1],
           color='red', s=120, edgecolor='black', linewidth=1.5, label='Конечная точка (f*)')

ax.set_xlabel('x₁', fontsize=12)
ax.set_ylabel('x₂', fontsize=12)
ax.set_zlabel('Значение функции', fontsize=12)
ax.set_title('Поверхность f(x₁, x₂) с наложенными траекториями f и P(X, r)', fontsize=14)
ax.legend(fontsize=10, loc='upper left')

# Цветовая шкала для поверхности f
fig.colorbar(surf, ax=ax, shrink=0.5, aspect=15, label='f(x₁, x₂)')
ax.set_zlim(-12, 20)
plt.tight_layout()
plt.show()