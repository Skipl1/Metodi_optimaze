#import "../../lib/lib.typ": *

// Центрирование заголовков
#show heading: set align(center)

// Изменение префикса подписей на "График"
#set figure( supplement: [График])

= Введение

Цель работы — ознакомление с методикой расчета оптимальных параметров регулятора при заданной структурной автоматической системы регулирования и заданных параметрах регулирования по интегральным критериям качества процесса регулирования.

#figure(
  image("extracted_content/images/Picture11111111111111.png", width: 50%),
  caption: [Структурная схема системы]
)

Передаточная функция объекта:

$ W_"об"(p) = k_"об" / (T_"об"^2 p^2 + 2 ζ T_"об" p + 1) * λ^(-τ_"об" p) $

Передаточная функция регулятора:

$ W_"рег"(p) = q_1 + q_2/p + q_3 p $

Параметры объекта:

$ k_"об" = 1, quad T_"об" = 1, quad ζ = 0,75, quad τ_"об" = 0,1 $

Критерий оптимизации:

$ I_3 = ∫_(0)^(∞) (x^2(t) + μ^2 hat(x)^2(t)) d t $

#pagebreak()

= Ход работы

$W(p) = k / (T^2 p^2 + 2 ζ T p + 1) $– колебательное звено

Распишем переход от передаточной функции к дифференциальному уравнению:

$ W(p) = k / (T^2 p^2 + 2 ζ T p + 1) = y/g $

$ T^2 (d^2 y)/(d t^2) + 2 T ζ (d y)/(d t) + y = k g $

Избавимся от коэффициента, тогда:

$ (d^2 y)/(d t^2) + (2 ζ)/T (d y)/(d t) + y/T^2 = k/T^2 g $

Коэффициенты для пространства состояний:

$ a_2 = 1, quad a_1 = (2 ζ)/T, quad a_0 = 1/T^2, quad b_0 = k/T^2, quad b_1 = b_2 = 0, z_3 = 0 $

Подготовим звено к моделированию методом непосредственного интегрирования:
$ y = z_1 + b_2 g = z_1 $
$ (d z_1)/(d t) = -(a_1 y - b_1 g) + z_2 = -(2 ζ)/T y + z_2 $
$ (d z_2)/(d t) = -(a_0 y - b_0 g) + z_3 = -y/T^2 + k/T^2 g $

Путем преобразований исходное дифференциальное уравнение второго порядка сводится к эквивалентной системе из двух уравнений первого порядка:

$ cases(
  y = z_1,
  (d z_1)/(d t) = -(2 ζ)/T y + z_2,
  (d z_2)/(d t) = -y/T^2 + k/T^2 g,
) $

Применяя метод Рунге-Кутта получаем:
$ cases(
  x = g - y quad y = z_1,
  k_1 = "dt" (z_2 - (2 ζ)/T y),
  m_1 = "dt" (k/T^2 x - y/T^2),
  k_2 = "dt" (z_2 + m_1/2 - (2 ζ)/T (y + k_1/2)),
  m_2 = "dt" (k/T^2 x - 1/T^2 (y + k_1/2)),
  k_3 = "dt" (z_2 + m_2/2 - (2 ζ)/T (y + k_2/2)),
  m_3 = "dt" (k/T^2 x - 1/T^2 (y + k_2/2)),
  k_4 = "dt" (z_2 + m_3 - (2 ζ)/T (y + k_3)),
  m_4 = "dt" (k/T^2 x - 1/T^2 (y + k_3))
) $

$ z_1 = z_1 + 1/6 (k_1 + 2 k_2 + 2 k_3 + k_4) $

$ z_2 = z_2 + 1/6 (m_1 + 2 m_2 + 2 m_3 + m_4) $

#pagebreak()

= Моделирование замкнутой системы без ПИД-регулятора

Код для моделирования:

```html
<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
google.charts.load("current", { packages: ["corechart"] });
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
  var T = 1;
  var k = 1;
  var zeta = 0.75;
  var tau = 0.1;
  var g = 1;
  var dt = 0.01;
  var L = 7;
  var ns = Math.round(tau / dt);
  var mas = [];
  var z1 = 0;
  var z2 = 0;
  var y_now = 0;
  var y_delayed = 0;
  var x;
  var k1, k2, k3, k4, m1, m2, m3, m4;
  var t_ = 0;
  var A = [["t", "y(t) - без запаздывания", "y(t) - с запаздыванием", "g(t) - вход"]];

  while (t_ <= L) {
    y_now = z1;
    mas.push(y_now);
    if (mas.length > ns) {
      y_delayed = mas.shift();
    } else {
      y_delayed = 0;
    }
    x = g - y_delayed;
    A.push([t_, y_now, y_delayed, g]);

    k1 = dt * (z2 - ((2 * zeta) / T) * y_now);
    m1 = dt * ((k / (T * T)) * x - y_now / (T * T));

    k2 = dt * (z2 + m1 / 2 - ((2 * zeta) / T) * (y_now + k1 / 2));
    m2 = dt * ((k / (T * T)) * x - (1 / (T * T)) * (y_now + k1 / 2));

    k3 = dt * (z2 + m2 / 2 - ((2 * zeta) / T) * (y_now + k2 / 2));
    m3 = dt * ((k / (T * T)) * x - (1 / (T * T)) * (y_now + k2 / 2));

    k4 = dt * (z2 + m3 - ((2 * zeta) / T) * (y_now + k3));
    m4 = dt * ((k / (T * T)) * x - (1 / (T * T)) * (y_now + k3));

    z1 = z1 + (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
    z2 = z2 + (1 / 6) * (m1 + 2 * m2 + 2 * m3 + m4);
    t_ = t_ + dt;
  }

  var data = google.visualization.arrayToDataTable(A);
  var options = {
    curveType: "function",
    hAxis: { title: "Время t, с" },
    vAxis: { title: "Амплитуда" },
    legend: { position: "bottom" },
    colors: ["#2980b9", "#c0392b", "#f1c40f"],
    lineWidth: 2
  };
  var chart = new google.visualization.LineChart(document.getElementById("curve_chart"));
  chart.draw(data, options);
}
</script>
</head>
<body>
<div class="conteiner" style="display: flex; justify-content: center">
  <div id="curve_chart" style="width: 900px; height: 600px"></div>
</div>
</body>
</html>
```

График:

#figure(
  image("extracted_content/images/image_2.png", width: 76%),
  caption: [Переходный процесс без ПИД-регулятора]
)

Смоделируем данную систему в SimInTech и сравним результаты графиков:

Структурная схема:

#figure(
  image("extracted_content/images/image_3.png", width: 60%),
  caption: [Структурная схема без ПИД-регулятора]
)

График:

#figure(
  image("extracted_content/images/image_4.png", width: 80%),
  caption: [Переходный процесс в SimInTech]
)

Как мы видим, графики полностью совпадают, значит наше ручное решение верное.

#pagebreak()

= Моделирование замкнутой системы с ПИД-регулятором

Передаточная функция регулятора:

$ W_"рег"(p) = q_1 + q_2/p + q_3 p $

Уравнения системы:

$ u(t, q) = W_"рег"(p) x(t, q) $

$ y(t, q) = W_"об"(p) u(t, q) $

ПИД-регулятор во временной области:

$ u(t, q) = q_1 x(t, q) + q_2 ∫ x(t, q) d t + q_3 (d x(t, q))/(d t) $

Для подбора оптимальных параметров $q_1, q_2, q_3$ необходим критерий оптимизации. В качестве такого критерия воспользуемся составным интегральным функционалом:

$ I_3 = ∫_(0)^(∞) (x^2(t) + μ^2 hat(x)^2(t)) d t $

Код для моделирования:

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <script
      type="text/javascript"
      src="https://www.gstatic.com/charts/loader.js"
    ></script>
    <script type="text/javascript">
      google.charts.load("current", { packages: ["corechart"] });
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var T = 1;
        var k = 1;
        var zeta = 0.75;
        var tau = 0.1;
        var g = 1;
        var dt = 0.01;
        var L = 9;
        var ns = Math.round(tau / dt);
        var mas = [];
        var z1 = 0;
        var z2 = 0;
        var y_now = 0;
        var y_delayed = 0;
        var x,
          x_prev = 0;
        var intx = 0;
        var dx;
        var u;
        var t_ = 0;
        var I = 0;
        var mu = 0.01;
        var q1 = 1;
        var q2 = 1;
        var q3 = 1;
        var A = [
          [
            "t",
            "y(t) - без запаздывания",
            "y(t) - с запаздыванием",
            "g(t) - вход",
            "I(t) - ошибка",
          ],
        ];

        x_prev = g - y_delayed;
        while (t_ <= L) {
          y_now = z1;
          mas.push(y_now);
          y_delayed = mas.length > ns ? mas.shift() : 0;
          x = g - y_delayed;
          intx += x * dt;
          dx = (x - x_prev) / dt;
          u = q1 * x + q2 * intx + q3 * dx;
          x_prev = x;
          I = I + (x * x + mu * mu * dx * dx) * dt;
          A.push([t_, y_now, y_delayed, g, I]);

          k1 = dt * (z2 - ((2 * zeta) / T) * y_now);
          m1 = dt * ((k / (T * T)) * u - y_now / (T * T));

          k2 = dt * (z2 + m1 / 2 - ((2 * zeta) / T) * (y_now + k1 / 2));
          m2 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k1 / 2));

          k3 = dt * (z2 + m2 / 2 - ((2 * zeta) / T) * (y_now + k2 / 2));
          m3 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k2 / 2));

          k4 = dt * (z2 + m3 - ((2 * zeta) / T) * (y_now + k3));
          m4 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k3));

          z1 = z1 + (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
          z2 = z2 + (1 / 6) * (m1 + 2 * m2 + 2 * m3 + m4);
          t_ = t_ + dt;
        }

        console.log("Итоговое значение интегральной ошибки I:", I);
        var data = google.visualization.arrayToDataTable(A);
        var options = {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: {
            title: "Амплитуда",
            viewWindow: { min: -0.2, max: 1.2 },
          },
          legend: { position: "bottom" },
          colors: ["#2980b9", "#c0392b", "#f1c40f", "#27ae60", "#8e44ad"],
          lineWidth: 2,
          chartArea: { width: "85%", height: "75%" },
        };
        var chart = new google.visualization.LineChart(
          document.getElementById("curve_chart"),
        );
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div class="conteiner" style="display: flex; justify-content: center">
      <div id="curve_chart" style="width: 900px; height: 600px"></div>
    </div>
  </body>
</html>
```

График при параметрах $q_1 = q_2 = q_3 = 1$:

#figure(
  image("extracted_content/images/image_5.png", width: 80%),
  caption: [Переходный процесс с ПИД-регулятором (начальные параметры)]
)

Итоговое значение интегральной ошибки $I$: $1,1663$

#pagebreak()

= Подбор оптимальных параметров ПИД-регулятора методом покоординатного спуска

*Основная идея метода:* Покоординатный спуск — это итерационный метод оптимизации, при котором на каждом шаге оптимизируется только один параметр, а остальные фиксируются. Цикл повторяется до сходимости.

*Алгоритм:*

#block(
  radius: 4pt,
  [
    #enum(
      [Инициализировать начальные значения параметров $q_1, q_2, q_3$ и шаг $h$.],
      [
        Для каждого параметра $q_i$ ($i = 1, 2, 3$):
        #enum(
          [Вычислить значение критерия $I$ при текущих значениях параметров.],
          [Увеличить $q_i$ на шаг $h$ и вычислить новый критерий $I_+$.],
          [Уменьшить $q_i$ на шаг $h$ (от начального значения) и вычислить критерий $I_-$.],
          [Если $I_+ < I$ и $I_+ < I_-$, принять $q_i = q_i + h$.],
          [Иначе, если $I_- < I$, принять $q_i = q_i - h$.],
        )
      ],
      [Если ни один параметр не изменился на шаге 2, уменьшить шаг: $h = h / 2$.],
      [Повторять шаги 2–3, пока шаг $h$ не станет меньше заданной точности $ε$.],
    )
  ]
)

Код для оптимизации:

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <script
      type="text/javascript"
      src="https://www.gstatic.com/charts/loader.js"
    ></script>
    <script type="text/javascript">
      google.charts.load("current", { packages: ["corechart"] });
      google.charts.setOnLoadCallback(optimizeAndDrawChart);

      function get_error(q1, q2, q3) {
        var T = 1;
        var k = 1;
        var zeta = 0.75;
        var tau = 0.1;
        var g = 1;
        var dt = 0.01;
        var L = 9;
        var z1 = 0;
        var z2 = 0;
        var y_now = 0;
        var y_delayed = 0;
        var x,
          x_prev = 0;
        var intx = 0;
        var dx;
        var u;
        var t_ = 0;
        var I = 0;
        var mu = 0.01;
        var ns = Math.round(tau / dt); // кол-во шагов задержки
        var history = new Array(ns).fill(0); // буфер для хранения прошлых y
        var y_delayed = 0;

        x_prev = g - y_delayed;
        while (t_ <= L) {
          y_now = z1;
          y_delayed = history.length >= ns ? history.shift() : 0;
          history.push(y_now);
          x = g - y_delayed;
          intx += x * dt;
          dx = (x - x_prev) / dt;
          u = q1 * x + q2 * intx + q3 * dx;
          x_prev = x;
          I = I + (x * x + mu * mu * dx * dx) * dt;

          k1 = dt * (z2 - ((2 * zeta) / T) * y_now);
          m1 = dt * ((k / (T * T)) * u - y_now / (T * T));

          k2 = dt * (z2 + m1 / 2 - ((2 * zeta) / T) * (y_now + k1 / 2));
          m2 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k1 / 2));

          k3 = dt * (z2 + m2 / 2 - ((2 * zeta) / T) * (y_now + k2 / 2));
          m3 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k2 / 2));

          k4 = dt * (z2 + m3 - ((2 * zeta) / T) * (y_now + k3));
          m4 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k3));

          z1 = z1 + (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
          z2 = z2 + (1 / 6) * (m1 + 2 * m2 + 2 * m3 + m4);
          t_ = t_ + dt;
        }
        return I;
      }

      function optimizeAndDrawChart() {
        var q = [1.0, 0.0, 0.0];
        var step = 1;
        var eps = 0.01;
        var best_I = get_error(q[0], q[1], q[2]);
        var changed = true;

        while (step > eps) {
          changed = false;
          for (var i = 0; i < 3; i++) {
            var q_plus = [...q];
            var q_minus = [...q];
            q_plus[i] += step;
            q_minus[i] -= step;

            var I_plus = get_error(q_plus[0], q_plus[1], q_plus[2]);
            var I_minus =
              q_minus[i] >= 0
                ? get_error(q_minus[0], q_minus[1], q_minus[2])
                : Infinity;

            if (I_plus < best_I && I_plus < I_minus) {
              q[i] = q_plus[i];
              best_I = I_plus;
              changed = true;
            } else if (I_minus < best_I) {
              q[i] = q_minus[i];
              best_I = I_minus;
              changed = true;
            }
          }
          if (!changed) {
            step = step / 2;
          }
        }

        document.getElementById("optimal_params").innerHTML =
          "<b>Оптимальные параметры:</b><br>" +
          "q1 = " +
          q[0].toFixed(4) +
          "<br>" +
          "q2 = " +
          q[1].toFixed(4) +
          "<br>" +
          "q3 = " +
          q[2].toFixed(4) +
          "<br>" +
          "Минимальная ошибка I = " +
          best_I.toFixed(5);

        var T = 1;
        var k = 1;
        var zeta = 0.75;
        var tau = 0.1;
        var g = 1;
        var dt = 0.01;
        var L = 9;
        var ns = Math.round(tau / dt);
        var mas = [];
        var z1 = 0;
        var z2 = 0;
        var y_now = 0;
        var x,
          x_prev = 0;
        var intx = 0;
        var dx;
        var u;
        var t_ = 0;
        var I = 0;
        var mu = 0.01;
        var A = [["t", "y(t)", "y(t) с зап.", "g(t)", "I(t)"]];

        x_prev = g - y_now;
        while (t_ <= L) {
          y_now = z1;
          mas.push(y_now);
          y_delayed = mas.length > ns ? mas.shift() : 0;
          x = g - y_delayed;
          intx += x * dt;
          dx = (x - x_prev) / dt;
          u = q[0] * x + q[1] * intx + q[2] * dx;
          x_prev = x;
          I = I + (x * x + mu * mu * dx * dx) * dt;
          A.push([t_, y_now, y_delayed, g, I]);

          k1_r = dt * (z2 - ((2 * zeta) / T) * y_now);
          m1_r = dt * ((k / (T * T)) * u - y_now / (T * T));

          k2_r = dt * (z2 + m1_r / 2 - ((2 * zeta) / T) * (y_now + k1_r / 2));
          m2_r = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k1_r / 2));

          k3_r = dt * (z2 + m2_r / 2 - ((2 * zeta) / T) * (y_now + k2_r / 2));
          m3_r = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k2_r / 2));

          k4_r = dt * (z2 + m3_r - ((2 * zeta) / T) * (y_now + k3_r));
          m4_r = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k3_r));

          z1 += (1 / 6) * (k1_r + 2 * k2_r + 2 * k3_r + k4_r);
          z2 += (1 / 6) * (m1_r + 2 * m2_r + 2 * m3_r + m4_r);
          t_ += dt;
        }

        var data = google.visualization.arrayToDataTable(A);
        var chart = new google.visualization.LineChart(
          document.getElementById("curve_chart"),
        );
        chart.draw(data, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: {
            title: "Амплитуда",
            viewWindow: { min: -0.2, max: 1.2 },
          },
          legend: { position: "bottom" },
          colors: ["#2980b9", "#c0392b", "#f1c40f", "#8e44ad"],
          chartArea: { width: "85%", height: "75%" },
        });
      }
    </script>
  </head>
  <body>
    <div class="conteiner" style="display: flex; justify-content: center">
      <div id="curve_chart" style="width: 900px; height: 600px"></div>
    </div>
    <div
      style="
        display: flex;
        justify-content: center;
        font-family: sans-serif;
        margin-top: -20px;
      "
    >
      <div
        id="optimal_params"
        style="
          background: #f4f4f4;
          padding: 15px;
          border-radius: 8px;
          border: 1px solid #ddd;
        "
      ></div>
    </div>
  </body>
</html>
```

Найдём оптимальные параметры:

#figure(
  image("extracted_content/images/image_7.png", width: 60%),
  caption: [Оптимальные параметры ПИД-регулятора]
)

График:

#figure(
  image("extracted_content/images/image_8.png", width: 90%),
  caption: [Переходный процесс с оптимальными параметрами]
)

Сравним графики с реализацией в SimInTech:

Схема:

#figure(
  image("extracted_content/images/image_9.png", width: 80%),
  caption: [Структурная схема в SimInTech]
)

График:

#figure(
  image("extracted_content/images/image_10.png", width: 80%),
  caption: [Переходный процесс в SimInTech]
)

Критерий улучшился в $(1,1663)/(0,24811) = 4,7010$ раза.

#pagebreak()

= Расчёт функции чувствительности

При реализации алгоритма параметрической оптимизации градиентным методом необходимы значения каждой составляющей вектор-градиента целевой функции $ (∂I(x(t,q)))/(∂q_j) $

В общем виде составляющие градиента имеют вид:

$ (∂I)/(∂q_j) = ∫_(0)^(∞) (∂F(x(t,q),t))/(∂x) · (∂x(t,q))/(∂q_j) d t $

Учитывая, что для исследуемой системы ошибка определяется как $x(t,q) = g(t) - y(t,q)$, а входной сигнал не зависит от параметров регулятора, получим:

$ (∂x(t,q))/(∂q_j) = (∂(g(t) - y(t,q)))/(∂q_j) = -(∂y(t,q))/(∂q_j) = -ξ_j(t) $

Здесь $ξ_j = (∂y(t,q))/(∂q_j)$ — называется **функцией чувствительности**, которая характеризует влияние $j$-го настраиваемого параметра $q_j$ на выходную координату объекта регулирования.

Таким образом, для вычисления градиента необходимо предварительно вычислить три функции чувствительности $ξ_j$, так как ПИД-регулятор имеет три настраиваемых параметра ($j = 1, 2, 3$).

В соответствии со структурной схемой исследуемой системы:

$ y(t,q) = W_"об"(p) u(t,q) $

$ u(t,q) = W_"рег"(p) x(t) = q_1 x(t) + q_2/p x(t) + q_3 p x(t) $

Дифференцируя частным образом правую и левую части и учитывая независимость $W_"об"(p)$ от настраиваемых параметров $q_j$, получим:

$ ξ_j = (∂y(t,q))/(∂q_j) = W_"об"(p) (∂u(t,q))/(∂q_j), quad j = 1, 2, 3 $

Т.е. функция чувствительности представляет собой выходную координату модели объекта регулирования с входной координатой $(∂u(t,q))/(∂q_j)$.

Таким образом, для вычисления значений функций чувствительности $ξ_j$ необходимо подать на вход объекта регулирования сигнал, соответствующий $j$-ой частной производной управляющего сигнала $(∂u(t,q))/(∂q_j)$.

Для ПИД-регулятора $u(t, q) = (q_1 + q_2/p + q_3 p) x(t)$ частные производные управляющего сигнала имеют вид:

$
  cases(
    (∂u)/(∂q_1) = x(t) - q_1 ξ_1(t) - q_2/p ξ_1(t) - q_3 p ξ_1(t),
    (∂u)/(∂q_2) = 1/p x(t) - q_1 ξ_2(t) - q_2/p ξ_2(t) - q_3 p ξ_2(t),
    (∂u)/(∂q_3) = p x(t) - q_1 ξ_3(t) - q_2/p ξ_3(t) - q_3 p ξ_3(t)
  )
 $

Полученные сигналы $(∂u)/(∂q_j)$ подаются на вход модели объекта регулирования $W_"об"(p)$, с выхода которой снимаются значения функций чувствительности $ξ_1(t), ξ_2(t), ξ_3(t)$.

#figure(
  image("extracted_content/images/sensitivity_before.png", width: 67%),
  caption: [Функции чувствительности ξ₁(t), ξ₂(t), ξ₃(t) и ошибка x(t) ДО оптимизации]
)

#figure(
  image("extracted_content/images/sensitivity_after.png", width: 60%),
  caption: [Функции чувствительности ξ₁(t), ξ₂(t), ξ₃(t) и ошибка x(t) ПОСЛЕ оптимизации]
)

#pagebreak()

= Алгоритм градиентного спуска с нормализацией и адаптивным шагом

*Основная идея метода:* Алгоритм ищет минимум, двигаясь строго против градиента. Чтобы избежать резких скачков параметров на крутых участках, вектор градиента нормализуется — так мы получаем только направление, а длину шага $h$ контролируем сами.

*Алгоритм:*

+ Задаются начальные значения параметров регулятора $q^(0) = [q_1^(0), q_2^(0), q_3^(0)]$, начальный шаг $h^(0) > 0$, точность по градиенту $epsilon > 0$ и минимально допустимый шаг $h_(min)$. Полагаем номер итерации $l = 0$.

+ Для текущих параметров $q^(l)$ численно решается система дифференциальных уравнений. Определяются:
  - ошибка регулирования $x(t, q^(l))$;
  - функции чувствительности $xi_j (t, q^(l))$ (с учетом запаздывания $tau$);
  - текущее значение критерия качества $I(q^(l)) = integral_0^(T_"мод") x^2 (t, q^(l)) d t$.

+ Вычисляются компоненты градиента:
  $ (partial I) / (partial q_j) = -2 integral_0^(T_"мод") x(t, q^(l)) dot xi_j (t, q^(l)) d t, quad j = 1, 2, 3 $
  Вычисляется евклидова норма градиента:
  $ ||nabla I|| = sqrt(sum_(j=1)^3 ((partial I) / (partial q_j))^2) $
  Если $||nabla I|| < epsilon$, алгоритм завершается.

+ Вычисляются новые значения параметров ("пробная точка"):
  $ q_j^(t r y) = q_j^(l) - h^(l) dot ( (partial I / partial q_j) ) / ( ||nabla I|| ), quad j = 1, 2, 3 $
  Применяется ограничение $q_j^(t r y) = max(0, q_j^(t r y))$, чтобы исключить отрицательные значения коэффициентов.

+ Проводится моделирование системы с параметрами $q^(t r y)$ и вычисляется новый критерий $I(q^(t r y))$.
  - *Если* $I(q^(t r y)) < I(q^(l))$ (Успех):
    Принимаем новые параметры: $q^(l+1) = q^(t r y)$.
    Увеличиваем шаг для следующей итерации: $h^(l+1) = h^(l) dot 1.05$.
    Переходим к Шагу 2 с $l = l + 1$.
  - *Если* $I(q^(t r y)) >= I(q^(l))$ (Неудача):
    Параметры не обновляются: $q^(l+1) = q^(l)$.
    Уменьшаем шаг: $h^(l) = h^(l) dot 0.5$.
    Если $h^(l) < h_(min)$, алгоритм завершается. В противном случае возвращаемся к Шагу 4 для повторного совершения пробного шага из той же точки.

Код:

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <script
      type="text/javascript"
      src="https://www.gstatic.com/charts/loader.js"
    ></script>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 20px;
        background: #f5f6fa;
      }
      .container {
        display: flex;
        justify-content: center;
        margin: 20px 0;
      }
      #result_info {
        background: #fff;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        max-width: 800px;
        margin: 20px auto;
        text-align: center;
        font-size: 16px;
      }
    </style>
    <script type="text/javascript">
      google.charts.load("current", { packages: ["corechart"] });
      google.charts.setOnLoadCallback(drawChart);

      // ============================================================================
      // Симуляция с расчётом функций чувствительности и градиента
      // Градиент: ∂I/∂qj = -2 ∫ x(t) · ξj(t) dt
      // ============================================================================
      function simulate(q1, q2, q3) {
        var T = 1,
          k = 1,
          zeta = 0.75,
          tau = 0.1,
          g = 1,
          dt = 0.01,
          L = 40;
        var z1 = 0,
          z2 = 0;
        var x,
          x_prev = g,
          intx = 0,
          dx,
          u;
        var I = 0;
        var eta1 = 0,
          eta2 = 0,
          eta3 = 0;
        var nu1 = 0,
          nu2 = 0,
          nu3 = 0;
        var int_xi1 = 0,
          int_xi2 = 0,
          int_xi3 = 0;
        var gradI1 = 0,
          gradI2 = 0,
          gradI3 = 0;
        var data = [],
          gradData = [];
        var t_ = 0;

        // --- Настройка запаздывания ---
        var delaySteps = Math.max(1, Math.round(tau / dt));
        var historyY = new Array(delaySteps).fill(0);
        var historyXi1 = new Array(delaySteps).fill(0);
        var historyXi2 = new Array(delaySteps).fill(0);
        var historyXi3 = new Array(delaySteps).fill(0);

        while (t_ <= L) {
          var y_now = z1;

          // Извлекаем задержанные значения (состояние системы tau секунд назад)
          var y_delayed = historyY.shift();
          var xi1_delayed = historyXi1.shift();
          var xi2_delayed = historyXi2.shift();
          var xi3_delayed = historyXi3.shift();

          // ОШИБКА теперь считается по задержанному сигналу
          x = g - y_delayed;
          intx += x * dt;
          dx = (x - x_prev) / dt;
          x_prev = x;
          u = q1 * x + q2 * intx + q3 * dx;
          I += x * x * dt;

          // Обновляем историю (добавляем текущие значения в конец очереди)
          historyY.push(y_now);
          historyXi1.push(eta1);
          historyXi2.push(eta2);
          historyXi3.push(eta3);

          // Расчет производных управления по параметрам (с учетом задержки xi)
          // d(dx)/dqj теперь тоже зависит от изменения задержанной xi
          var dxi1_dt = nu1,
            dxi2_dt = nu2,
            dxi3_dt = nu3;

          var du_dq1 = x - q1 * xi1_delayed - q2 * int_xi1 - q3 * dxi1_dt;
          var du_dq2 = intx - q1 * xi2_delayed - q2 * int_xi2 - q3 * dxi2_dt;
          var du_dq3 = dx - q1 * xi3_delayed - q2 * int_xi3 - q3 * dxi3_dt;

          // Уравнения чувствительности (динамика объекта)
          var dnu1_dt =
            (k / (T * T)) * du_dq1 -
            ((2 * zeta) / T) * nu1 -
            (1 / (T * T)) * eta1;
          var dnu2_dt =
            (k / (T * T)) * du_dq2 -
            ((2 * zeta) / T) * nu2 -
            (1 / (T * T)) * eta2;
          var dnu3_dt =
            (k / (T * T)) * du_dq3 -
            ((2 * zeta) / T) * nu3 -
            (1 / (T * T)) * eta3;

          // Эйлер для чувствительности
          eta1 += nu1 * dt;
          eta2 += nu2 * dt;
          eta3 += nu3 * dt;
          nu1 += dnu1_dt * dt;
          nu2 += dnu2_dt * dt;
          nu3 += dnu3_dt * dt;

          int_xi1 += xi1_delayed * dt;
          int_xi2 += xi2_delayed * dt;
          int_xi3 += xi3_delayed * dt;

          // Градиент: используем xi_delayed, так как ошибка x(t) вызвана именно этой xi
          gradI1 += -2 * x * xi1_delayed * dt;
          gradI2 += -2 * x * xi2_delayed * dt;
          gradI3 += -2 * x * xi3_delayed * dt;

          data.push([t_, x, eta1, eta2, eta3]);
          gradData.push([
            t_,
            -2 * x * xi1_delayed,
            -2 * x * xi2_delayed,
            -2 * x * xi3_delayed,
          ]);

          // Рунге-Кутта 4 для самого объекта
          var k1 = dt * (z2 - ((2 * zeta) / T) * y_now);
          var m1 = dt * ((k / (T * T)) * u - y_now / (T * T));
          var k2 = dt * (z2 + m1 / 2 - ((2 * zeta) / T) * (y_now + k1 / 2));
          var m2 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k1 / 2));
          var k3 = dt * (z2 + m2 / 2 - ((2 * zeta) / T) * (y_now + k2 / 2));
          var m3 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k2 / 2));
          var k4 = dt * (z2 + m3 - ((2 * zeta) / T) * (y_now + k3));
          var m4 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k3));

          z1 += (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
          z2 += (1 / 6) * (m1 + 2 * m2 + 2 * m3 + m4);
          t_ += dt;
        }
        return {
          I: I,
          grad: [gradI1, gradI2, gradI3],
          data: data,
          gradData: gradData,
        };
      }

      // ============================================================================
      // Градиентный спуск с нормализацией
      // q_j[l] = q_j[l-1] - h · (∂I/q_j) / ||I||
      // ============================================================================
      function gradientNorm(grad) {
        return Math.sqrt(
          grad[0] * grad[0] + grad[1] * grad[1] + grad[2] * grad[2],
        );
      }

      function clampParams(q) {
        return q.map((val) => Math.max(0.0, val));
      }

      function runGradientDescent(qStart, hInit, maxIter) {
        var q = qStart.slice();
        var h = hInit; // Текущий шаг
        var history = [];

        // Считаем начальное состояние
        var currentResult = simulate(q[0], q[1], q[2]);
        var currentI = currentResult.I;

        for (var iter = 0; iter < maxIter; iter++) {
          var grad = currentResult.grad;
          var norm = gradientNorm(grad);

          if (norm < 0.0001) break; // Сходимость достигнута

          // 1. Пробуем сделать шаг
          var qNext = [];
          for (var i = 0; i < 3; i++) {
            qNext.push(q[i] - (h * grad[i]) / norm);
          }
          qNext = clampParams(qNext); // Не пускаем коэффициенты в минус

          // 2. Симулируем систему с НОВЫМИ параметрами
          var nextResult = simulate(qNext[0], qNext[1], qNext[2]);
          var nextI = nextResult.I;

          // 3. Проверяем: стало лучше или хуже?
          if (nextI < currentI) {
            // УСПЕХ: ошибка уменьшилась
            q = qNext;
            currentI = nextI;
            currentResult = nextResult;
            h *= 1.05; // Немного увеличиваем шаг, чтобы идти быстрее (оптимизм)

            // Записываем историю только успешных шагов
            history.push({
              iter: iter + 1,
              q1: q[0],
              q2: q[1],
              q3: q[2],
              I: currentI,
              norm: norm,
              h: h, // Записываем текущий шаг для отладки
            });
          } else {
            // ПРОВАЛ: мы перепрыгнули минимум или система стала неустойчивой
            h *= 0.5; // Резко уменьшаем шаг (осторожность)
            // Параметры q не обновляем, на следующей итерации попробуем шаг поменьше

            // Если шаг стал совсем крошечным, выходим
            if (h < 1e-7) break;
          }
        }

        return {
          q: q,
          I: currentI,
          grad: currentResult.grad,
          history: history,
        };
      }

      function drawChart() {
        var qInit = [1.0, 0.0, 0.0];
        var hStart = 1.0; // Можно начать с большого шага
        var maxIter = 2000; // Адаптивному шагу обычно нужно меньше итераций
        var optResult = runGradientDescent(qInit, hStart, maxIter);

        // Вывод оптимальных параметров
        document.getElementById("result_info").innerHTML =
          "<strong>Оптимальные параметры:</strong> q* = [" +
          optResult.q[0].toFixed(4) +
          ", " +
          optResult.q[1].toFixed(4) +
          ", " +
          optResult.q[2].toFixed(4) +
          "]<br>" +
          "<strong>Критерий:</strong> I* = " +
          optResult.I.toFixed(4) +
          "<br>" +
          "<strong>Градиент:</strong> [" +
          optResult.grad[0].toFixed(6) +
          ", " +
          optResult.grad[1].toFixed(6) +
          ", " +
          optResult.grad[2].toFixed(6) +
          "]<br>" +
          "<strong>Норма градиента:</strong> ||∇I|| = " +
          gradientNorm(optResult.grad).toFixed(6);

        var simBefore = simulate(qInit[0], qInit[1], qInit[2]);
        var simAfter = simulate(optResult.q[0], optResult.q[1], optResult.q[2]);

        // График 1: Функции чувствительности ДО оптимизации
        var A_before = [["t", "x(t)", "ξ1(t)", "ξ2(t)", "ξ3(t)"]];
        for (var i = 0; i < simBefore.data.length; i++)
          A_before.push(simBefore.data[i]);
        var dataBefore = google.visualization.arrayToDataTable(A_before);
        new google.visualization.LineChart(
          document.getElementById("curve_chart"),
        ).draw(dataBefore, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: { title: "Амплитуда" },
          legend: { position: "bottom" },
          colors: ["#c0392b", "#27ae60", "#8e44ad", "#e67e22"],
          lineWidth: 2,
          title:
            "ДО оптимизации (q = [" +
            qInit[0].toFixed(2) +
            ", " +
            qInit[1].toFixed(2) +
            ", " +
            qInit[2].toFixed(2) +
            "])",
        });

        // График 2: Функции чувствительности ПОСЛЕ оптимизации
        var A_after = [["t", "x(t)", "ξ1(t)", "ξ2(t)", "ξ3(t)"]];
        for (var i = 0; i < simAfter.data.length; i++)
          A_after.push(simAfter.data[i]);
        var dataAfter = google.visualization.arrayToDataTable(A_after);
        new google.visualization.LineChart(
          document.getElementById("after_chart"),
        ).draw(dataAfter, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: { title: "Амплитуда" },
          legend: { position: "bottom" },
          colors: ["#c0392b", "#27ae60", "#8e44ad", "#e67e22"],
          lineWidth: 2,
          title:
            "ПОСЛЕ оптимизации (q* = [" +
            optResult.q[0].toFixed(2) +
            ", " +
            optResult.q[1].toFixed(2) +
            ", " +
            optResult.q[2].toFixed(2) +
            "])",
        });

        // График 3: Подынтегральные выражения градиента
        var B = [["t", "d(∂I/∂q₁)/dt", "d(∂I/∂q₂)/dt", "d(∂I/∂q₃)/dt"]];
        for (var i = 0; i < simAfter.gradData.length; i++)
          B.push(simAfter.gradData[i]);
        var dataGrad = google.visualization.arrayToDataTable(B);
        new google.visualization.LineChart(
          document.getElementById("grad_chart"),
        ).draw(dataGrad, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: { title: "Амплитуда" },
          legend: { position: "bottom" },
          colors: ["#c0392b", "#27ae60", "#8e44ad"],
          lineWidth: 2,
        });

        // График 4: Сходимость градиентного спуска
        var C = [["Итерация", "Критерий I"]];
        for (var i = 0; i < optResult.history.length; i++)
          C.push([optResult.history[i].iter, optResult.history[i].I]);
        var dataConv = google.visualization.arrayToDataTable(C);
        new google.visualization.LineChart(
          document.getElementById("convergence_chart"),
        ).draw(dataConv, {
          curveType: "function",
          hAxis: { title: "Итерация" },
          vAxis: { title: "Критерий I" },
          legend: { position: "none" },
          colors: ["#2980b9"],
          lineWidth: 2,
        });
      }
    </script>
  </head>
  <body>
    <div id="result_info"></div>
    <h3 style="text-align: center">
      Функции чувствительности ξ₁(t), ξ₂(t), ξ₃(t) и ошибка x(t) — ДО
      оптимизации
    </h3>
    <div class="container">
      <div id="curve_chart" style="width: 1200px; height: 700px"></div>
    </div>
    <h3 style="text-align: center">
      Функции чувствительности ξ₁(t), ξ₂(t), ξ₃(t) и ошибка x(t) — ПОСЛЕ
      оптимизации
    </h3>
    
    <div class="container">
      <div id="after_chart" style="width: 1200px; height: 700px"></div>
    </div>

    <h3 style="text-align: center">Подынтегральные выражения градиента</h3>
    <div class="container">

      <div id="grad_chart" style="width: 1200px; height: 500px"></div>
    </div>
    <h3 style="text-align: center">Сходимость градиентного спуска</h3>
    <div class="container">

      <div id="convergence_chart" style="width: 1200px; height: 500px"></div>
    </div>
  </body>
</html>
```

*Результаты моделирования:*
#figure(
  image("extracted_content/images/grad.png", width: 50%),
  caption: [Оптимальные параметры ПИД-регулятора, полученные методом градиентного спуска с нормализацией]
)
#figure(
  image("extracted_content/images/gradient_integrands.png", width: 80%),
  caption: [Подынтегральные выражения градиента]
)

#figure(
  image("extracted_content/images/convergence.png", width: 70%),
  caption: [Сходимость градиентного спуска]
)


#figure(
  image("extracted_content/images/itog.png", width: 80%),
  caption: [Переходный процесс с оптимальными параметрами (q₁ = 35.686, q₂ = 4.0382, q₃ = 7.9786)]
)


#pagebreak()

= Алгоритм наискорейшего спуска с линейным поиском (I₃(2))

*Основная идея метода:* Метод наискорейшего спуска — это градиентный метод оптимизации, в котором на каждой итерации движение осуществляется в направлении антиградиента (направлении наибыстрейшего убывания функционала). Ключевое отличие от простого градиентного спуска — наличие внутреннего цикла линейного поиска: шаг в выбранном направлении выполняется до тех пор, пока функционал уменьшается.

*Критерий оптимизации (I₃(2)):* В отличие от стандартного критерия $I_3 = ∫ x^2(t) d t$, используется модифицированный функционал, минимизирующий отклонение от эталонной модели:

$ I_3^{(2)} = ∫_(0)^(L) (y(t) - y_"эт"(t))^2 d t $

где $y(t)$ — выходной сигнал оптимизируемой системы, $y_"эт"(t)$ — выход эталонной модели.

*Эталонная модель:* Инерционное звено первого порядка:

$ W_"эт"(p) = k_"эт" / (T_"эт" p + 1) $

с параметрами $k_"эт" = 1$, $T_"эт" = 0.4$.

Расчёт выхода эталонной модели производится численно методом Рунге-Кутты 4-го порядка:

$
  cases(
    k_1 = "dt" (-y_"эт" / T_"эт" + k_"эт" / T_"эт" * g),
    k_2 = "dt" (-(y_"эт" + k_1 / 2) / T_"эт" + k_"эт" / T_"эт" * g),
    k_3 = "dt" (-(y_"эт" + k_2 / 2) / T_"эт" + k_"эт" / T_"эт" * g),
    k_4 = "dt" (-(y_"эт" + k_3) / T_"эт" + k_"эт" / T_"эт" * g),
  )
$

$ y_"эт" = y_"эт" + 1/6 (k_1 + 2 k_2 + 2 k_3 + k_4) $

*Градиент функционала:* Для критерия $I_3(2)$ градиент вычисляется по формуле:

$ (∂I)/(∂q_j) = 2 ∫_(0)^(L) (y(t) - y_"эт"(t)) · ξ_j(t) d t, quad j = 1, 2, 3 $

где $ξ_j(t) = (∂y(t))/(∂q_j)$ — функции чувствительности.

*Алгоритм:*

+ Задаются начальные значения параметров регулятора $q^(0) = [q_1^(0), q_2^(0), q_3^(0)]$, начальный шаг $h^(0) > 0$, точность по градиенту $epsilon = 10^(-5)$. Полагаем номер итерации $k = 0$.

+ Для текущих параметров $q^(k)$ численно решается система дифференциальных уравнений. Определяются:
  - ошибка регулирования $x(t, q^(k)) = g(t) - y(t, q^(k))$;
  - выход эталонной модели $y_"эт"(t)$;
  - разность $Δ(t) = y(t, q^(k)) - y_"эт"(t)$;
  - функции чувствительности $xi_j (t, q^(k))$ (с учетом запаздывания $tau$);
  - текущее значение критерия качества $I(q^(k)) = integral_0^(L) Δ^2 (t) d t$.

+ Вычисляются компоненты градиента:
  $ (partial I) / (partial q_j) = 2 integral_0^(L) Δ(t) dot xi_j (t, q^(k)) d t, quad j = 1, 2, 3 $
  Вычисляется евклидова норма градиента:
  $ ||nabla I|| = sqrt(sum_(j=1)^3 ((partial I) / (partial q_j))^2) $
  Если $||nabla I|| < epsilon$, алгоритм завершается.

+ Определяется направление наискорейшего спуска (единичный вектор):
  $ S = - (nabla I) / (||nabla I||), quad "т.е." quad S_j = - ( ((partial I )/ (partial q_j) )) / ( ||nabla I|| ), quad j = 1, 2, 3 $

+ Линейный поиск вдоль направления S:
  #enum(
    [Полагаем $q_"лучш" = q^(k)$, $I_"лучш" = I(q^(k))$, $h_"тек" = h^(k)$, счётчик шагов $n = 0$.],
    [В цикле (максимум 100 шагов):
      #enum(
        [Вычислить пробные параметры: $q_"проб" = q^(k) + h_"тек" · S$.],
        [Применить ограничение: $q_"проб" = max(0, q_"проб")$.],
        [Вычислить $I(q_"проб")$.],
        [Если $I(q_"проб") < I_"лучш"$:
          #enum(
            [Принять $q_"лучш" = q_"проб"$, $I_"лучш" = I(q_"проб")$.],
            [Увеличить шаг: $h_"тек" = h_"тек" · 1.2$.],
            [Увеличить счётчик: $n = n + 1$.],
            [Продолжить цикл.],
          )
        ],
        [Иначе (перелёт через минимум): выйти из цикла.],
      )
    ],
  )

+ Обновить параметры: $q^(k+1) = q_"лучш"$, $I(q^(k+1)) = I_"лучш"$.

+ Если на шаге 5 не было сделано ни одного успешного шага ($n = 0$):
  #enum(
    [Уменьшить начальный шаг: $h^(k) = h^(k) / 2$.],
    [Если $h^(k) < 10^(-7)$, завершить алгоритм.],
  )
  Иначе сбросить шаг к начальному: $h^(k+1) = h^(0)$.

+ Увеличить номер итерации: $k = k + 1$. Вернуться к шагу 2.

*Код реализации:*

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <script
      type="text/javascript"
      src="https://www.gstatic.com/charts/loader.js"
    ></script>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 20px;
        background: #f5f6fa;
      }
      .container {
        display: flex;
        justify-content: center;
        margin: 20px 0;
      }
      #result_info {
        background: #fff;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        max-width: 800px;
        margin: 20px auto;
        text-align: center;
        font-size: 16px;
      }
    </style>
    <script type="text/javascript">
      google.charts.load("current", { packages: ["corechart"] });
      google.charts.setOnLoadCallback(drawChart);

      // Функция симуляции - считает I и градиент
      function simulate(q1, q2, q3) {
        var T = 1,
          k = 1,
          zeta = 0.75,
          tau = 0.1,
          g = 1,
          dt = 0.01,
          L = 40;
        var z1 = 0,
          z2 = 0;
        var x,
          x_prev = g,
          intx = 0,
          dx,
          u;
        var I = 0;
        var eta1 = 0,
          eta2 = 0,
          eta3 = 0;
        var nu1 = 0,
          nu2 = 0,
          nu3 = 0;
        var int_xi1 = 0,
          int_xi2 = 0,
          int_xi3 = 0;
        var gradI1 = 0,
          gradI2 = 0,
          gradI3 = 0;
        var data = [],
          gradData = [];
        var t_ = 0;

        // Параметры эталонной модели
        var T_ref = 0.6,
          k_ref = 1;
        var y_ref_prev = 0;

        // Запаздывание
        var delaySteps = Math.max(1, Math.round(tau / dt));
        var historyY = new Array(delaySteps).fill(0);
        var historyXi1 = new Array(delaySteps).fill(0);
        var historyXi2 = new Array(delaySteps).fill(0);
        var historyXi3 = new Array(delaySteps).fill(0);

        while (t_ <= L) {
          var y_now = z1;

          // Достаём задержанные значения
          var y_delayed = historyY.shift();
          var xi1_delayed = historyXi1.shift();
          var xi2_delayed = historyXi2.shift();
          var xi3_delayed = historyXi3.shift();

          // Ошибка по задержанному сигналу
          x = g - y_delayed;
          intx += x * dt;
          dx = (x - x_prev) / dt;
          x_prev = x;
          u = q1 * x + q2 * intx + q3 * dx;

          // Эталонная модель (Рунге-Кутта 4)
          var obrat_g = g;
          var k1_ref = dt * (-(y_ref_prev / T_ref) + (k_ref / T_ref) * obrat_g);
          var k2_ref =
            dt *
            (-(y_ref_prev + k1_ref / 2) / T_ref + (k_ref / T_ref) * obrat_g);
          var k3_ref =
            dt *
            (-(y_ref_prev + k2_ref / 2) / T_ref + (k_ref / T_ref) * obrat_g);
          var k4_ref =
            dt * (-(y_ref_prev + k3_ref) / T_ref + (k_ref / T_ref) * obrat_g);
          var y_ref =
            y_ref_prev + (1 / 6) * (k1_ref + 2 * k2_ref + 2 * k3_ref + k4_ref);
          y_ref_prev = y_ref;

          // Разница с эталоном
          var diff = y_delayed - y_ref;

          // Функционал I
          I += diff * diff * dt;

          // Обновляем историю
          historyY.push(y_now);
          historyXi1.push(eta1);
          historyXi2.push(eta2);
          historyXi3.push(eta3);

          // Производные управления
          // d(dx)/dqj теперь тоже зависит от изменения задержанной xi
          var dxi1_dt = nu1,
            dxi2_dt = nu2,
            dxi3_dt = nu3;

          var du_dq1 = x - q1 * xi1_delayed - q2 * int_xi1 - q3 * dxi1_dt;
          var du_dq2 = intx - q1 * xi2_delayed - q2 * int_xi2 - q3 * dxi2_dt;
          var du_dq3 = dx - q1 * xi3_delayed - q2 * int_xi3 - q3 * dxi3_dt;

          // Уравнения чувствительности (динамика объекта)
          var dnu1_dt =
            (k / (T * T)) * du_dq1 -
            ((2 * zeta) / T) * nu1 -
            (1 / (T * T)) * eta1;
          var dnu2_dt =
            (k / (T * T)) * du_dq2 -
            ((2 * zeta) / T) * nu2 -
            (1 / (T * T)) * eta2;
          var dnu3_dt =
            (k / (T * T)) * du_dq3 -
            ((2 * zeta) / T) * nu3 -
            (1 / (T * T)) * eta3;

          // Эйлер для чувствительности
          eta1 += nu1 * dt;
          eta2 += nu2 * dt;
          eta3 += nu3 * dt;
          nu1 += dnu1_dt * dt;
          nu2 += dnu2_dt * dt;
          nu3 += dnu3_dt * dt;

          int_xi1 += xi1_delayed * dt;
          int_xi2 += xi2_delayed * dt;
          int_xi3 += xi3_delayed * dt;

          // Новый градиент: ∂I/∂qj = 2 ∫ (y - y_эт) · ξj dt
          gradI1 += 2 * diff * xi1_delayed * dt;
          gradI2 += 2 * diff * xi2_delayed * dt;
          gradI3 += 2 * diff * xi3_delayed * dt;

          data.push([t_, x, eta1, eta2, eta3, y_ref, y_delayed]);
          gradData.push([
            t_,
            2 * diff * xi1_delayed,
            2 * diff * xi2_delayed,
            2 * diff * xi3_delayed,
          ]);

          // Рунге-Кутта 4 для самого объекта
          var k1 = dt * (z2 - ((2 * zeta) / T) * y_now);
          var m1 = dt * ((k / (T * T)) * u - y_now / (T * T));
          var k2 = dt * (z2 + m1 / 2 - ((2 * zeta) / T) * (y_now + k1 / 2));
          var m2 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k1 / 2));
          var k3 = dt * (z2 + m2 / 2 - ((2 * zeta) / T) * (y_now + k2 / 2));
          var m3 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k2 / 2));
          var k4 = dt * (z2 + m3 - ((2 * zeta) / T) * (y_now + k3));
          var m4 = dt * ((k / (T * T)) * u - (1 / (T * T)) * (y_now + k3));

          z1 += (1 / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
          z2 += (1 / 6) * (m1 + 2 * m2 + 2 * m3 + m4);
          t_ += dt;
        }
        return {
          I: I,
          grad: [gradI1, gradI2, gradI3],
          data: data,
          gradData: gradData,
        };
      }

      // Метод наискорейшего спуска (градиент + линейный поиск)
      function gradientNorm(grad) {
        return Math.sqrt(
          grad[0] * grad[0] + grad[1] * grad[1] + grad[2] * grad[2],
        );
      }

      function clampParams(q) {
        return q.map((val) => Math.max(0.0, val));
      }

      function runSteepestDescent(qStart, hInit, maxIter) {
        var q = qStart.slice();
        var h = hInit;
        var history = [];
        var totalIter = 0;

        // Начальное состояние
        var currentResult = simulate(q[0], q[1], q[2]);
        var currentI = currentResult.I;

        while (totalIter < maxIter) {
          var grad = currentResult.grad;
          var norm = gradientNorm(grad);

          // Проверка сходимости
          if (norm < 1e-5) break;

          // Направление спуска
          var S = [-grad[0] / norm, -grad[1] / norm, -grad[2] / norm];

          // Линейный поиск
          var qBest = q.slice();
          var IBest = currentI;
          var stepCount = 0;
          var hCurrent = h;

          while (stepCount < 100) {
            var qNext = [];
            for (var i = 0; i < 3; i++) {
              qNext.push(q[i] + hCurrent * S[i]);
            }
            qNext = clampParams(qNext);

            var nextResult = simulate(qNext[0], qNext[1], qNext[2]);
            var nextI = nextResult.I;

            if (nextI < IBest) {
              qBest = qNext.slice();
              IBest = nextI;
              q = qNext.slice();
              hCurrent *= 1.2;
              stepCount++;
            } else {
              break;
            }
          }

          q = qBest.slice();
          currentI = IBest;
          currentResult = simulate(q[0], q[1], q[2]);

          // Записываем историю
          history.push({
            iter: totalIter + 1,
            q1: q[0],
            q2: q[1],
            q3: q[2],
            I: currentI,
            norm: norm,
          });

          totalIter++;

          if (stepCount === 0) {
            h *= 0.5;
            if (h < 1e-7) break;
          } else {
            h = hInit;
          }
        }

        return {
          q: q,
          I: currentI,
          grad: currentResult.grad,
          history: history,
        };
      }

      function drawChart() {
        // 3 набора параметров
        var qInit_sets = [
          [1.0, 0.0, 0.0],
          [0.1, 0.01, 7.0],
          [10.0, 2.0, 0.0],
        ];

        var qInit = qInit_sets[0];
        var hStart = 0.5;
        var maxIter = 1000;
        var optResult = runSteepestDescent(qInit, hStart, maxIter);

        // Запускаем оптимизацию для всех 3 наборов
        var optResult1 = runSteepestDescent(qInit_sets[0], hStart, maxIter);
        var optResult2 = runSteepestDescent(qInit_sets[1], hStart, maxIter);
        var optResult3 = runSteepestDescent(qInit_sets[2], hStart, maxIter);

        // Вывод оптимальных параметров
        document.getElementById("result_info").innerHTML =
          "<strong>Оптимальные параметры:</strong> q* = [" +
          optResult.q[0].toFixed(4) +
          ", " +
          optResult.q[1].toFixed(4) +
          ", " +
          optResult.q[2].toFixed(4) +
          "]<br>" +
          "<strong>Критерий:</strong> I* = " +
          optResult.I.toFixed(4) +
          "<br>" +
          "<strong>Градиент:</strong> [" +
          optResult.grad[0].toFixed(6) +
          ", " +
          optResult.grad[1].toFixed(6) +
          ", " +
          optResult.grad[2].toFixed(6) +
          "]<br>" +
          "<strong>Норма градиента:</strong> ||∇I|| = " +
          gradientNorm(optResult.grad).toFixed(6);

        var simBefore = simulate(qInit[0], qInit[1], qInit[2]);
        var simAfter = simulate(optResult.q[0], optResult.q[1], optResult.q[2]);

        // === ГРАФИКИ ДЛЯ ТРЁХ НАБОРОВ НАЧАЛЬНЫХ ПАРАМЕТРОВ ===
        // Общий график: все 3 набора ДО оптимизации + ПОСЛЕ оптимизации + эталонная модель

        var simSet1_before = simulate(
          qInit_sets[0][0],
          qInit_sets[0][1],
          qInit_sets[0][2],
        );
        var simSet2_before = simulate(
          qInit_sets[1][0],
          qInit_sets[1][1],
          qInit_sets[1][2],
        );
        var simSet3_before = simulate(
          qInit_sets[2][0],
          qInit_sets[2][1],
          qInit_sets[2][2],
        );

        var simSet1_after = simulate(
          optResult1.q[0],
          optResult1.q[1],
          optResult1.q[2],
        );
        var simSet2_after = simulate(
          optResult2.q[0],
          optResult2.q[1],
          optResult2.q[2],
        );
        var simSet3_after = simulate(
          optResult3.q[0],
          optResult3.q[1],
          optResult3.q[2],
        );

        // График 1: Переходные процессы (3 набора ДО и ПОСЛЕ + эталон)
        var transAllData = [
          [
            "t",
            "Набор 1: q=[1.0, 0.0, 0.0]",
            "Набор 2: q=[0.1, 0.01, 7.0]",
            "Набор 3: q=[10.0, 2.0, 0.0]",
            "q*=[" +
              optResult1.q[0].toFixed(2) +
              ", " +
              optResult1.q[1].toFixed(2) +
              ", " +
              optResult1.q[2].toFixed(2) +
              "]",
            "y_эт(t)",
          ],
        ];
        for (var i = 0; i < simSet1_before.data.length; i++) {
          transAllData.push([
            simSet1_before.data[i][0],
            simSet1_before.data[i][6],
            simSet2_before.data[i][6],
            simSet3_before.data[i][6],
            simSet1_after.data[i][6],
            simSet1_after.data[i][5],
          ]);
        }
        var dataTransAll = google.visualization.arrayToDataTable(transAllData);
        new google.visualization.LineChart(
          document.getElementById("all_sets_chart"),
        ).draw(dataTransAll, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: { title: "Амплитуда" },
          legend: { position: "bottom" },
          colors: ["#e74c3c", "#3498db", "#f1c40f", "#27ae60", "#2ecc71"],
          lineWidth: 2,
          title: "Переходные процессы: 3 набора",
        });

        // График 2: Подынтегральные выражения градиента
        var gradDataAll = [
          ["t", "d(∂I/∂q₁)/dt", "d(∂I/∂q₂)/dt", "d(∂I/∂q₃)/dt"],
        ];
        for (var i = 0; i < simSet1_after.gradData.length; i++)
          gradDataAll.push(simSet1_after.gradData[i]);
        var dataGradAll = google.visualization.arrayToDataTable(gradDataAll);
        new google.visualization.LineChart(
          document.getElementById("grad_all_chart"),
        ).draw(dataGradAll, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: { title: "Амплитуда" },
          legend: { position: "bottom" },
          colors: ["#c0392b", "#27ae60", "#8e44ad"],
          lineWidth: 2,
          title: "Подынтегральные выражения градиента",
        });

        // График 3: Функции чувствительности
        var sensDataAll = [["t", "ξ1(t)", "ξ2(t)", "ξ3(t)"]];
        for (var i = 0; i < simSet1_after.data.length; i++) {
          sensDataAll.push([
            simSet1_after.data[i][0],
            simSet1_after.data[i][2],
            simSet1_after.data[i][3],
            simSet1_after.data[i][4],
          ]);
        }
        var dataSensAll = google.visualization.arrayToDataTable(sensDataAll);
        new google.visualization.LineChart(
          document.getElementById("sens_all_chart"),
        ).draw(dataSensAll, {
          curveType: "function",
          hAxis: { title: "Время t, с" },
          vAxis: { title: "Амплитуда" },
          legend: { position: "bottom" },
          colors: ["#27ae60", "#8e44ad", "#e67e22"],
          lineWidth: 2,
          title: "Функции чувствительности",
        });

        // График 4: Сходимость I
        var convAllData = [["Итерация", "Набор 1", "Набор 2", "Набор 3"]];
        var maxLen = Math.min(
          100,
          optResult1.history.length,
          optResult2.history.length,
          optResult3.history.length,
        );
        for (var i = 0; i < maxLen; i++) {
          var v1 = optResult1.history[i].I;
          var v2 = optResult2.history[i].I;
          var v3 = optResult3.history[i].I;
          convAllData.push([i + 1, v1, v2, v3]);
        }
        var dataConvAll = google.visualization.arrayToDataTable(convAllData);
        new google.visualization.LineChart(
          document.getElementById("conv_all_chart"),
        ).draw(dataConvAll, {
          curveType: "function",
          hAxis: { title: "Итерация" },
          vAxis: { title: "Критерий I" },
          legend: { position: "bottom" },
          colors: ["#e74c3c", "#3498db", "#f1c40f"],
          lineWidth: 2,
          title: "Сходимость I (I* = " + optResult1.I.toFixed(4) + ")",
        });

        // Сходимость q1
        var F_q1 = [["Итерация", "Набор 1", "Набор 2", "Набор 3"]];
        var maxLenQ = Math.max(
          optResult1.history.length,
          optResult2.history.length,
          optResult3.history.length,
        );
        for (var i = 0; i < maxLenQ; i++) {
          var v1 =
            i < optResult1.history.length
              ? optResult1.history[i].q1
              : optResult1.q[0];
          var v2 =
            i < optResult2.history.length
              ? optResult2.history[i].q1
              : optResult2.q[0];
          var v3 =
            i < optResult3.history.length
              ? optResult3.history[i].q1
              : optResult3.q[0];
          F_q1.push([i + 1, v1, v2, v3]);
        }
        var dataQ1 = google.visualization.arrayToDataTable(F_q1);
        new google.visualization.LineChart(
          document.getElementById("q1_conv_chart"),
        ).draw(dataQ1, {
          curveType: "function",
          hAxis: { title: "Итерация" },
          vAxis: { title: "q1" },
          legend: { position: "bottom" },
          colors: ["#e74c3c", "#3498db", "#f1c40f"],
          lineWidth: 2,
          title: "Сходимость q1 → " + optResult1.q[0].toFixed(2),
        });

        // Сходимость q2
        var F_q2 = [["Итерация", "Набор 1", "Набор 2", "Набор 3"]];
        for (var i = 0; i < maxLenQ; i++) {
          var v1 =
            i < optResult1.history.length
              ? optResult1.history[i].q2
              : optResult1.q[1];
          var v2 =
            i < optResult2.history.length
              ? optResult2.history[i].q2
              : optResult2.q[1];
          var v3 =
            i < optResult3.history.length
              ? optResult3.history[i].q2
              : optResult3.q[1];
          F_q2.push([i + 1, v1, v2, v3]);
        }
        var dataQ2 = google.visualization.arrayToDataTable(F_q2);
        new google.visualization.LineChart(
          document.getElementById("q2_conv_chart"),
        ).draw(dataQ2, {
          curveType: "function",
          hAxis: { title: "Итерация" },
          vAxis: { title: "q2" },
          legend: { position: "bottom" },
          colors: ["#e74c3c", "#3498db", "#f1c40f"],
          lineWidth: 2,
          title: "Сходимость q2 → " + optResult1.q[1].toFixed(2),
        });

        // Сходимость q3
        var F_q3 = [["Итерация", "Набор 1", "Набор 2", "Набор 3"]];
        for (var i = 0; i < maxLenQ; i++) {
          var v1 =
            i < optResult1.history.length
              ? optResult1.history[i].q3
              : optResult1.q[2];
          var v2 =
            i < optResult2.history.length
              ? optResult2.history[i].q3
              : optResult2.q[2];
          var v3 =
            i < optResult3.history.length
              ? optResult3.history[i].q3
              : optResult3.q[2];
          F_q3.push([i + 1, v1, v2, v3]);
        }
        var dataQ3 = google.visualization.arrayToDataTable(F_q3);
        new google.visualization.LineChart(
          document.getElementById("q3_conv_chart"),
        ).draw(dataQ3, {
          curveType: "function",
          hAxis: { title: "Итерация" },
          vAxis: { title: "q3" },
          legend: { position: "bottom" },
          colors: ["#e74c3c", "#3498db", "#f1c40f"],
          lineWidth: 2,
          title: "Сходимость q3 → " + optResult1.q[2].toFixed(2),
        });
      }
    </script>
  </head>
  <body>
    <div id="result_info"></div>

    <h2 style="text-align: center; color: #2c3e50">
      Пункт 3: Подтверждение работоспособности алгоритма оптимизации
    </h2>

    <h3 style="text-align: center">3 набора</h3>
    <div class="container">
      <div id="all_sets_chart" style="width: 1200px; height: 700px"></div>
    </div>

    <h3 style="text-align: center">Подынтегральные выражения градиента</h3>
    <div class="container">
      <div id="grad_all_chart" style="width: 1200px; height: 500px"></div>
    </div>

    <h3 style="text-align: center">Функции чувствительности</h3>
    <div class="container">
      <div id="sens_all_chart" style="width: 1200px; height: 500px"></div>
    </div>

    <h3 style="text-align: center">Сходимость I</h3>
    <div class="container">
      <div id="conv_all_chart" style="width: 1200px; height: 500px"></div>
    </div>

    <h2 style="text-align: center; color: #2c3e50">
      Пункт 3.2: Сходимость параметров ПИД-регулятора
    </h2>

    <h3 style="text-align: center">Сходимость q1</h3>
    <div class="container">
      <div id="q1_conv_chart" style="width: 1200px; height: 500px"></div>
    </div>

    <h3 style="text-align: center">Сходимость q2</h3>
    <div class="container">
      <div id="q2_conv_chart" style="width: 1200px; height: 500px"></div>
    </div>

    <h3 style="text-align: center">Сходимость q3</h3>
    <div class="container">
      <div id="q3_conv_chart" style="width: 1200px; height: 500px"></div>
    </div>
  </body>
</html>
```

*Результаты моделирования:*

#figure(
  image("extracted_content/images/result_znach.png", width: 50%),
  caption: [Оптимальные параметры ПИД-регулятора, полученные методом наискорейшего спуска]
)

#figure(
  image("extracted_content/images/all_sets_transition.png", width: 80%),
  caption: [Переходные процессы: 3 набора]
)

#figure(
  image("extracted_content/images/grad_all.png", width: 80%),
  caption: [Подынтегральные выражения градиента]
)

#figure(
  image("extracted_content/images/sens_all.png", width: 80%),
  caption: [Функции чувствительности ξ₁(t), ξ₂(t), ξ₃(t)]
)

#figure(
  image("extracted_content/images/conv_all.png", width: 80%),
  caption: [Сходимость критерия I для всех 3 наборов]
)

#figure(
  image("extracted_content/images/q1_conv.png", width: 80%),
  caption: [Сходимость параметра q1 из 3 различных начальных точек]
)

#figure(
  image("extracted_content/images/q2_conv.png", width: 80%),
  caption: [Сходимость параметра q2 из 3 различных начальных точек]
)

#figure(
  image("extracted_content/images/q3_conv.png", width: 80%),
  caption: [Сходимость параметра q3 из 3 различных начальных точек]
)

#pagebreak()
