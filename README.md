BankApp (demo) — iOS (Swift / UIKit)

Это моё учебно-проектное приложение уровня «кошелёк». Хотел сделать аккуратный UI и разобраться с сетью, картами и темами. Без реальных платежей, только демо-функции и чистый код.

Что умеет

Курсы: 10 популярных фиатных валют, металлы (золото/серебро) и топ-крипта (BTC/ETH/USDT и др.).

Конвертер: быстрый пересчёт + история последних конвертаций.

Карта: поиск ближайших отделений, сортировка по расстоянию и построение маршрута.

Настройки: светлая/тёмная темы, общий градиентный фон, плоский таббар/навигация без «тяжёлых» теней.

Детали UX: единый стиль иконок криптовалют, флаги фиата, метка «обновлено только что».

Технологии

Ядро: Swift 5, UIKit, Auto Layout, Storyboard/xib, лёгкие анимации/жесты.

Сеть: URLSession + Codable, async/await; параллельная загрузка (async let, DispatchGroup), обработка ошибок и фолбэки.

Гео/карты: CoreLocation, MapKit (MKLocalSearch, MKDirections).

Данные: UserDefaults (настройки/тема), CoreData (история конвертаций).

Инфра: Xcode 15+, iOS 15+. Зависимостей через SPM/Pods не требуется.

Архитектура

Держу всё на простом MVC (местами MVVM). Сеть/данные вынес в «провайдеры», часто переиспользуемые куски — в отдельные вью/утилиты.

![IMAGE 2025-09-25 19:07:47](https://github.com/user-attachments/assets/eeb48720-1738-4093-8e5b-c4435f05a738)
![IMAGE 2025-09-25 19:07:52](https://github.com/user-attachments/assets/83fdbea4-b807-4942-9f7a-c3bf98bb2570)
![IMAGE 2025-09-25 19:07:56](https://github.com/user-attachments/assets/9cd2f069-af68-4683-886a-01c74d272c9c)
![IMAGE 2025-09-25 19:08:01](https://github.com/user-attachments/assets/df92a7db-8cf9-4beb-aa98-2ee1821c8aef)
![IMAGE 2025-09-25 19:08:05](https://github.com/user-attachments/assets/0e9250a9-a71c-437e-ab5a-432ddca7d07e)
![IMAGE 2025-09-25 19:08:08](https://github.com/user-attachments/assets/0fd2971b-1004-45bb-bfe8-9a3c07184893)
