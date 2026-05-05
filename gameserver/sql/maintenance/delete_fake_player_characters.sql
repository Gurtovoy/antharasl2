-- Удаление персонажей-ботов (FakePlayersTable: account_name = '#fake_account'; старые БД: 'fake').
-- Выполняйте при ОСТАНОВЛЕННОМ gameserver. После удаления перезапустите сервер — сработает очистка сирот в IdFactory.
-- При ошибке внешнего ключа сначала удалите вещи: UPDATE items ... или используйте полный maintenance из документации к IdFactory.

DELETE FROM characters WHERE account_name IN ('#fake_account', 'fake');
