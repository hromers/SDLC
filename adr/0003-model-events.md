---
status: accepted
date: 2026-11-19
decision-makers: Лапко М. А.
---

# 0003 Активная модель с уведомлением результата

## Контекст и постановка задачи

GUI должен обновляться после успешного расчета, включая смену тренажера при одинаковых числах. Отказ проверки не должен менять результат.

Связи: FR-002, FR-003, FR-006, FR-007, NFR-006; [SDD](../sdd/sdd-template.md).

## Драйверы решения

Обновление подписи при одинаковой зоне; отсутствие Swing в модели; сохранение текущих API.

## Рассмотренные варианты

PropertyChangeSupport; Прямой вызов представления из контроллера; Опрос модели по таймеру.

## Итог решения

Использовать PropertyChangeSupport: calculationResult с oldValue=null; MainView читает обновленные поля через геттеры. Проверки остаются в контроллере до calculateAndSave.

## Плюсы и минусы вариантов

Событие отделяет вычисление от представления и не требует опроса. Прямой вызов сильнее связывает контроллер с GUI; таймер создает лишние события и задержку.

## Последствия

Имя события является строковым контрактом. Модель сама не валидирует вход; прямые вызовы обязаны соблюдать предусловия. PropertyChangeSupport не переключает поток на EDT.

## Подтверждение

Инспекция processInput, firePropertyChange и propertyChange; сверка формулы и порядка обновления полей.

## Дополнительная информация

Статус accepted означает документирование уже существующего выбора автором, а не согласование внешним заказчиком. Статус proposed означает предложение для следующего релиза. [План и условия пересмотра](../plan/plan.md). Официальные контракты: [EDT](https://docs.oracle.com/javase/tutorial/uiswing/concurrency/dispatch.html), [PropertyChangeSupport](https://docs.oracle.com/en/java/javase/21/docs/api/java.desktop/java/beans/PropertyChangeSupport.html), [Toolkit](https://docs.oracle.com/en/java/javase/21/docs/api/java.desktop/java/awt/Toolkit.html).
