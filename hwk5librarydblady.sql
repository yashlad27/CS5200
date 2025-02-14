USE librarylady;

-- Question1 
-- For each book (found in the book table) , return the book’s ISBN, title, page count and publisher.
SELECT isbn, title, page_count, publisher_name FROM book;

-- verification
SELECT COUNT(*) AS total_books FROM book;

-- 2. (5 points) Determine the number of books that are checked out of the library. Rename the count on books_on_loan.
SELECT COUNT(*) AS books_on_loan FROM book WHERE available=0;

-- verification
SELECT isbn, title, available, current_holder 
FROM book 
WHERE available = 0;

-- 3. (5 points) Determine the number of members who have books checked out. Rename the count num_members.
SELECT COUNT(DISTINCT current_holder) AS num_members FROM book WHERE current_holder IS NOT NULL;

-- verification 
SELECT DISTINCT current_holder, 
       COUNT(*) as books_checked
FROM book 
WHERE current_holder IS NOT NULL
GROUP BY current_holder;

-- 4. (5 points) Make a separate table from the booktable – where the records are for the books on loan. Name the new table as books on loan. Remember, a table can only be created once. If you attempt to
-- create the same table multiple times it will generate an error.
SET sql_mode = 'STRICT_TRANS_TABLES';

CREATE TABLE books_on_loan AS SELECT * FROM book WHERE available=0;

CREATE TABLE books_on_loan AS
SELECT isbn, title, description, page_count, available, current_holder, publisher_name,
       DATE(publication_date) as publication_date
FROM book 
WHERE available = 0;

-- verification 
SELECT * FROM books_on_loan;
SELECT COUNT(*) FROM books_on_loan;

-- 5. (5 points) For each book return the book’s ISBN, title, description, page count, publisher name and
-- author. If a book has multiple authors, there should be multiple rows in your result.
SELECT b.isbn, b.title, b.description, b.page_count, b.publisher_name, a.name AS author
FROM book AS b
JOIN book_author AS ba ON b.isbn = ba.isbn
JOIN author a ON ba.author = a.name;

-- verification
SELECT COUNT(DISTINCT b.isbn) as total_books,
       COUNT(DISTINCT a.name) as total_authors
FROM book b
JOIN book_author AS ba 
ON b.isbn = ba.isbn
JOIN author AS a 
ON ba.author = a.name;

-- 6. (5 points) For each book (each ISBN in the book table) , create an aggregated field that contains a list
-- of the genres for the book.. The r`esult set should contain the isbn, the book title and the grouped list of
-- genres.
SELECT b.isbn, b.title, 
       GROUP_CONCAT(g.genre SEPARATOR ', ') AS genres
FROM book AS b
LEFT JOIN book_genre AS g ON b.isbn = g.isbn
GROUP BY b.isbn, b.title;

-- verification
SELECT b.isbn, b.title, COUNT(g.genre) as genre_count
FROM book AS b
LEFT JOIN book_genre AS g ON b.isbn = g.isbn
GROUP BY b.isbn, b.title
ORDER BY genre_count DESC;

-- 7. (5 points) Which are the longest books (in pages)? Return the book’s title in the result. Return all
-- books with the maximum number of pages.
SELECT title
FROM book 
WHERE page_count = (SELECT MAX(page_count) FROM book);

-- verification
SELECT title, page_count
FROM book
ORDER BY page_count DESC;

-- 8. (5 points) How many reading clubs are associated with each of the different librarians? The result
-- should contain the librarian’s user name and the count of the number of book clubs they have formed.
-- Rename the count to num_clubs. All librarians must appear in the result.
SELECT l.username, 
       COUNT(rc.name) AS num_clubs
FROM librarian AS l
LEFT JOIN reading_club AS rc ON l.username = rc.librarian
GROUP BY l.username;

-- verification
SELECT rc.librarian, rc.name AS club_name
FROM reading_club AS rc
ORDER BY rc.librarian;

-- 9. (5 points) Find all books that are less than 300 pages. Return all fields from the book table and order
-- the results by page count in descending order.
SELECT *
FROM book
WHERE page_count < 300
ORDER BY page_count DESC;

-- verification
SELECT COUNT(*) AS books_under_300,
       AVG(page_count) AS avg_pages
FROM book
WHERE page_count < 300;

-- 10. (5 points) For each genre in the genre table, determine the number of books associated with that
-- genre. The result should contain the genre name and the count. Rename the count to num
-- books. Order the results by num_books in descending order. Make sure all genres appear in the result. If a genre is not
-- associated with any books, then the count for the number of books should be 0.
SELECT * FROM genre;
SELECT * FROM book;

SELECT g.name, 
       COUNT(bg.isbn) AS num_books
FROM genre AS g
LEFT JOIN book_genre bg ON g.name = bg.genre
GROUP BY g.name
ORDER BY num_books DESC;

-- verification
SELECT COUNT(*) as total_genres,
       COUNT(DISTINCT bg.genre) as genres_with_books
FROM genre g
LEFT JOIN book_genre bg ON g.name = bg.genre;

-- 11. (5 points) For each current book in a reading club, return the ISBN, the title, the publisher, the number
-- of books published by the publisher, the author, the number of books written by the author, and the
-- librarian’s first name and last name.
SELECT * FROM book;
SELECT * FROM author;
SELECT * FROM librarian;

SELECT DISTINCT b.isbn, b.title, b.publisher_name,
       (SELECT COUNT(*) FROM book b2 WHERE b2.publisher_name = b.publisher_name) AS publisher_book_count,
       a.name AS author,
       a.books_written AS author_book_count,
       l.first_name, l.last_name
FROM book AS b
JOIN reading_club AS rc ON b.isbn = rc.current_book_isbn
JOIN book_author AS ba ON b.isbn = ba.isbn
JOIN author AS a ON ba.author = a.name
JOIN librarian AS l ON rc.librarian = l.username;

-- verification
SELECT COUNT(DISTINCT rc.current_book_isbn) as total_club_books,
       COUNT(DISTINCT rc.librarian) as total_librarians
FROM reading_club rc
WHERE rc.current_book_isbn IS NOT NULL;

-- 12. (5 points) Return the member’s username, who is a member in all book clubs.
SELECT m.username
FROM member AS m
WHERE NOT EXISTS (
    SELECT rc.name 
    FROM reading_club AS rc
    WHERE NOT EXISTS (
        SELECT 1 
        FROM reading_club_members AS rcm 
        WHERE rcm.club_name = rc.name 
        AND rcm.member_username = m.username
    )
);

-- verification
SELECT m.username, COUNT(DISTINCT rcm.club_name) AS clubs_joined
FROM member AS m
LEFT JOIN reading_club_members AS rcm ON m.username = rcm.member_username
GROUP BY m.username
ORDER BY clubs_joined DESC;

-- 13. (10 points) Find the authors who have written books for five or more distinct genres. Each result
-- tuple should include the author's name and the total number of distinct genres associated with that author.
-- Ensure that each author appears only once in the result, avoiding duplicates. Sort the output in descending
-- order based on genre count. Rename the count as genre count.
SELECT a.name,
       COUNT(DISTINCT bg.genre) AS genre_count
FROM author AS a
JOIN book_author AS ba ON a.name = ba.author
JOIN book_genre AS bg ON ba.isbn = bg.isbn
GROUP BY a.name
HAVING COUNT(DISTINCT bg.genre) >= 5
ORDER BY genre_count DESC;

-- verification
SELECT COUNT(*) as authors_5plus_genres
FROM (
    SELECT a.name
    FROM author AS a
    JOIN book_author AS  ba ON a.name = ba.author
    JOIN book_genre AS bg ON ba.isbn = bg.isbn
    GROUP BY a.name
    HAVING COUNT(DISTINCT bg.genre) >= 5
) t;


-- 14. (10 points) Find the publishers who have published books with an average page count greater than 500. The result should include the publisher's name ( publisher_name ), total number of distinct books published ( total
-- _books ), the genres their books belong to ( genres_published ), the authors they have contracted ( contracted_authors ), the average book length ( avg_book_length ), and the number of times
-- their books have been selected by reading clubs ( book_club_selection ). Ensure that publishers with no books published, genres, authors, or book club selections are appropriately handled. Return one tuple for
-- each publisher that satisfies the page count constraint.
SELECT 
    p.name AS publisher_name,
    COUNT(DISTINCT b.isbn) AS total_books,
    GROUP_CONCAT(DISTINCT bg.genre) AS genres_published,
    GROUP_CONCAT(DISTINCT ba.author) AS contracted_authors,
    AVG(b.page_count) AS avg_book_length,
    COUNT(DISTINCT rc.name) AS book_club_selection
FROM publisher AS p
LEFT JOIN book AS b ON p.name = b.publisher_name
LEFT JOIN book_genre AS bg ON b.isbn = bg.isbn
LEFT JOIN book_author AS ba ON b.isbn = ba.isbn
LEFT JOIN reading_club AS rc ON b.isbn = rc.current_book_isbn
GROUP BY p.name
HAVING AVG(b.page_count) > 500;

-- verification
SELECT 
    COUNT(*) AS publishers_over_500,
    AVG(avg_pages) AS overall_avg_pages
FROM (
    SELECT p.name, AVG(b.page_count) AS avg_pages
    FROM publisher AS p
    JOIN book AS b ON p.name = b.publisher_name
    GROUP BY p.name
    HAVING AVG(b.page_count) > 500
) t;


-- 15. (5 points) Find members who are in the same book club. Each returned tuple should contain the user
-- name for the 2 members in the same book club as well as the name of the book club. Order the results in
-- ascending order by the book club name. Make sure you do not match a member with himself. Also, only
-- report the same member pair once.
SELECT DISTINCT 
    m1.member_username AS member1,
    m2.member_username AS member2,
    m1.club_name
FROM reading_club_members m1
JOIN reading_club_members m2 
    ON m1.club_name = m2.club_name
    AND m1.member_username < m2.member_username
ORDER BY m1.club_name;

-- verification
SELECT club_name, COUNT(*) AS member_count
FROM reading_club_members
GROUP BY club_name
HAVING member_count > 1;

-- 16. (5 points) For each author, determine the number of books they have written. The result should
-- contain the author’s name and the count of books. Rename the count of books to num
-- books. Order the_results in descending order by num books.
SELECT a.name,
       COUNT(ba.isbn) AS num_books
FROM author AS a
LEFT JOIN book_author ba ON a.name = ba.author
GROUP BY a.name
ORDER BY num_books DESC;

-- verification
SELECT 
    MAX(book_count) AS max_books,
    MIN(book_count) AS min_books,
    AVG(book_count) AS avg_books
FROM (
    SELECT COUNT(ba.isbn) AS book_count
    FROM author AS a
    LEFT JOIN book_author ba ON a.name = ba.author
    GROUP BY a.name
) t;

-- 17. (5 Points) Find the isbn and title of the books ( book_title ) that are not part of any reading clubs.
SELECT b.isbn, b.title AS book_title
FROM book AS b
WHERE b.isbn NOT IN (
    SELECT current_book_isbn 
    FROM reading_club 
    WHERE current_book_isbn IS NOT NULL
);

-- verification
SELECT 
    COUNT(*) AS total_books,
    COUNT(DISTINCT rc.current_book_isbn) AS books_in_clubs,
    COUNT(*) - COUNT(DISTINCT rc.current_book_isbn) AS books_not_in_clubs
FROM book b
LEFT JOIN reading_club rc ON b.isbn = rc.current_book_isbn;

-- 18. (5 Points) Return the name of the authors who have written the maximum number of books. The result
-- should contain the author’s name and the book count.
SELECT a.name, 
       COUNT(ba.isbn) AS book_count
FROM author AS a
JOIN book_author AS ba ON a.name = ba.author
GROUP BY a.name
HAVING COUNT(ba.isbn) = (
    SELECT COUNT(isbn) 
    FROM book_author 
    GROUP BY author 
    ORDER BY COUNT(isbn) DESC 
    LIMIT 1
);

-- verification
SELECT MAX(book_count) AS max_books
FROM (
    SELECT COUNT(ba.isbn) AS book_count
    FROM author AS a
    JOIN book_author ba ON a.name = ba.author
    GROUP BY a.name
) t;
