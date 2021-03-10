CREATE TABLE venues (
  venue_id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL
);
CREATE TABLE destinations (
  destination_id SERIAL PRIMARY KEY,
  venue_id INTEGER REFERENCES venues ON DELETE CASCADE ON UPDATE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL
);
