CREATE TABLE book (
   book_id INT AUTO_INCREMENT PRIMARY KEY,
   author_id INT,
   title VARCHAR(255),
   isbn INT,
   available BOOL,
   genre_id INT
);

CREATE TABLE author (
   author_id INT AUTO_INCREMENT PRIMARY KEY,
   first_name VARCHAR(255),
   last_name VARCHAR(255),
   birthday DATE,
   deathday DATE
);

CREATE TABLE patron (
   patron_id INT AUTO_INCREMENT PRIMARY KEY,
   first_name VARCHAR(255),
   last_name VARCHAR(255),
   loan_id INT
);

CREATE TABLE reference_books (
   reference_id INT AUTO_INCREMENT PRIMARY KEY,
   edition INT,
   book_id INT,
   FOREIGN KEY (book_id)
      REFERENCES book(book_id)
      ON UPDATE SET NULL
      ON DELETE SET NULL
);

INSERT INTO reference_books(edition, book_id)
VALUE (5,32);

CREATE TABLE genre (
   genre_id INT PRIMARY KEY,
   genres VARCHAR(100)
);

CREATE TABLE loan (
   loan_id INT AUTO_INCREMENT PRIMARY KEY,
   patron_id INT,
   date_out DATE,
   date_in DATE,
   book_id INT,
   FOREIGN KEY (book_id)
      REFERENCES book(book_id)
      ON UPDATE SET NULL
      ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------------------------------------------------

-- return mystery book titles and their isbns - either of these will work. LIKE keyword can look for patterns as well as exact matches
SELECT title, isbn
FROM book 
WHERE genre_id IN (SELECT genre_id FROM genre WHERE genres = 'Mystery');

SELECT title, isbn
FROM book 
WHERE genre_id IN (SELECT genre_id FROM genre WHERE genres LIKE 'Mystery');

-- LIKE is not case sensitive
SELECT title, isbn
FROM book 
WHERE genre_id IN (SELECT genre_id FROM genre WHERE genres LIKE 'mystery');

-- This pattern means "starts with 'm'" so we get Mystery books and Memoir books
SELECT book.title, book.isbn, genre.genres 
FROM book
INNER JOIN genre ON book.genre_id = genre.genre_id 
WHERE genre.genres LIKE 'm%';

-- ----------------------------------------------------------------------------------------------------------------------

--     Return all of the titles and author’s first and last names for books written by authors who are currently living.
SELECT book.title, author.first_name, author.last_name 
FROM book
INNER JOIN author ON book.author_id = author.author_id 
WHERE author.deathday IS NULL;

-- ----------------------------------------------------------------------------------------------------------------------

-- LOAN OUT A BOOK
-- Change available to FALSE for the appropriate book.
UPDATE book
SET available = FALSE
WHERE book_id = 10;
-- Add a new row to the loan table with today’s date as the date_out and the ids in the row matching the appropriate patron_id and book_id.
INSERT INTO loan (date_out, patron_id, book_id)
VALUES (CURDATE(), 13, 10); 
-- Update the appropriate patron with the loan_id for the new row created in the loan table.
UPDATE patron
SET loan_id = 2 -- (SELECT loan_id FROM loan WHERE patron_id = 13)
WHERE patron_id = 13;

-- ----------------------------------------------------------------------------------------------------------------------

-- CHECK A BOOK BACK IN
-- Change available to TRUE for the appropriate book.
UPDATE book
SET available = TRUE
WHERE book_id = 10;
-- Update the appropriate row in the loan table with today’s date as the date_in.
UPDATE loan
SET date_in = CURDATE()
WHERE book_id = 10
-- AND patron_id = 13 AND date_in = NULL
;
-- Update the appropriate patron changing loan_id back to null
UPDATE patron
SET loan_id = NULL
WHERE patron_id = 13;

-- ----------------------------------------------------------------------------------------------------------------------

-- WRAP UP
-- This query should return the names of the patrons with the genre of every book they currently have checked out
SELECT patron_loan.first_name, patron_loan.last_name, genre_book.genres
FROM (
	SELECT patron.first_name, patron.last_name, loan.book_id
    FROM patron
    INNER JOIN loan ON loan.loan_id = patron.loan_id
) AS patron_loan
INNER JOIN (
	SELECT  genre.genre_id, genre.genres, book.book_id
    FROM genre
    INNER JOIN book ON genre.genre_id = book.genre_id) AS genre_book
ON genre_book.book_id = patron_loan.book_id;

-- ----------------------------------------------------------------------------------------------------------------------

-- BONUS MISSIONS
-- Return the counts of the books of each genre. Check out the documentation to see how this could be done!

SELECT genre_id, COUNT(*) FROM book GROUP BY genre_id;

-- A reference book cannot leave the library. How would you modify either the reference_book table or the book table to make sure that doesn’t happen? Try to apply your modifications.

UPDATE book
SET available = CASE
	WHEN genre_id = 25 THEN available
    ELSE FALSE
    END
WHERE book_id = 10;