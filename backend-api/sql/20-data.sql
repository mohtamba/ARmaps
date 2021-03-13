INSERT INTO venues(venue_id, name, description, image_url, latitude, longitude)
VALUES
    (DEFAULT, 'Michigan''s Adventure', 'Michigan''s Adventure is a 250-acre amusement park in Muskegon County, Michigan, about halfway between Muskegon and Whitehall. It is the largest amusement park in the state and has been owned and operated by Cedar Fair since 2001.', '/media/michiganadventurewaterpark.jpeg', 43.342079, -86.279846),
    (DEFAULT, 'Michigan Stadium', 'Michigan Stadium, nicknamed "The Big House", is the football stadium for the University of Michigan in Ann Arbor, Michigan. It is the largest stadium in the United States and Western Hemisphere, the third largest stadium in the world, and the 34th largest sports venue.', '/media/michiganstadium.jpeg', 42.265869, -83.750031);
INSERT INTO destinations(destination_id, venue_id, name, description, image_url, latitude, longitude)
VALUES
    (DEFAULT, 1, 'Shivering Timbers', 'At a half-mile out and a half-mile back in just two minutes and 30 seconds, Shivering Timbers is a solid mile of pure adrenaline, excitement and fun!', '/media/shiveringtimbers.jpeg', 43.342225, -86.277054),
    (DEFAULT, 1, 'Funnel of Fear', 'Take your best friends and family, add a bendy tunnel, a ginormous funnel, loads of screams and laughter, and what do you get? The Funnel of Fear at Michigan’s Adventure’s WildWater Adventure!', '/media/funneloffear.jpeg', 43.345509, -86.279666),
    (DEFAULT, 1, 'Thunderhawk', 'Have you ever dreamed of soaring through the air like a majestic hawk? Our Thunderhawk roller coaster, the first suspended looping coaster in the state, comes mighty close to delivering the next best thing!', '/media/thunderhawk.jpeg', 43.345412, -86.277281),
    (DEFAULT, 2, 'Gate 10', 'Northeast entrance gate, also known as the student entrance.', '/media/gate10.jpeg', 42.267576, -83.747683),
    (DEFAULT, 2, 'Gate 4', 'Southwest entrance gate, also known as the main entrance.', '/media/gate4.jpeg', 42.264514, -83.749918),
    (DEFAULT, 2, 'North Snack Bar', 'Located between the two entrances on Keech Ave, we sell hotdogs, popcorn, and soft pretzels!', '/media/snackbar.jpeg', 42.267416, -83.749060);
