Storage = {}


Storage.Init = function()
    lib.print.debug("Checking and Creating Database Tables")
    MySQL.rawExecute.await([[
        CREATE TABLE IF NOT EXISTS `trucker_vehicles` (
            `citizenid` INTEGER PRIMARY KEY,
            `plate` TEXT,
            `model` TEXT,
            `fuel` INTEGER
        );

        CREATE TABLE IF NOT EXISTS `trucker_trailers` (
            `citizenid` INTEGER PRIMARY KEY,
            `plate` TEXT,
            `model` TEXT
        );

        CREATE TABLE IF NOT EXISTS `trucker_users` (
            `citizenid` INTEGER PRIMARY KEY,
            `bank` INTEGER,
            `xp` INTEGER,
            `level` INTEGER,
            `xpMultiplier` INTEGER
        );

        CREATE TABLE IF NOT EXISTS `trucker_data_trailers` (
            `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
            `data` TEXT
        );
    ]])
    lib.print.debug("Database Tables Created (If they didn't exist)")
end

return Storage
