return {
    Features = {
        Target = false, -- if false requires sleepless-ineraction
        NpcTalk = true, -- if enabled, it will uses the interaction from mt_lib. 
        UseCreatePed = true, -- if enabled, it will use mt_lib to create the ped.
    },
    incomePerMiles = 20,
    jobTypes = {
        long = "Long-Distance Delivery",
        incity = "In-City Delivery",
    },
    depoLocations = {
        ["main-depo"] = {
            label = "In City Depot",
            position = vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
            vehicleSpawns = {
                vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
                vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
                vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
                vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
                vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
            },
            blip = {
                Sprite = 50,
                Color = 2,
                Scale = 0.8,
                Name = "PostOP Depot",
                Position = vector4(-416.9915, -2763.1121, 6.0004, 191.3396),
            }
        },
    },
    trailerCreator = {
        position = vector4(3040.5361, -4678.7949, 15.2616, 81.0353),
    },
    trailerTypes = {
        ["tanker2"] = "Tanker",
        ["trailers2"] = "Trailer",
    },
    TrailerBases = {
        ["trflat"] = "Flat Trailer",
        ["armytrailer"] = "Army Trailer",
        ["freighttrailer"] = "Freight Trailer",
    },
    DepotPed = {
        Ped = "a_m_y_business_02",
        Anim = {
            dict = "missfam4",
            clip = "base",
        }
    }
}
