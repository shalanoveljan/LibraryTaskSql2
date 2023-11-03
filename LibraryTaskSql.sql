

use Kitabxana1

Create Table Authors 
(
 Id int identity primary key,
    Name nvarchar(50),
    Surname nvarchar(50)
)
INSERT INTO Authors 
VALUES
('F. Scott', 'Fitzgerald'),
('Harper', 'Lee'),
('George', 'Orwell'),
('Jane', 'Austen'),
('J.D.', 'Salinger');



Create Table Books
(
Id int identity primary key ,
Name nvarchar(100) Check(Len(Name) Between 2 And 100),
PageCount int Check(PageCount>=10),
 AuthorId int Foreign Key References Authors(Id)
)

INSERT INTO Books
VALUES
('The Great Gatsby', 180, 1),
('To Kill a Mockingbird', 281, 2),
('1984', 328, 3),
('Pride and Prejudice', 416, 4),
('The Catcher in the Rye', 224, 5),
('Moby-Dick', 635, 1),
('The Grapes of Wrath', 479, 2)





Create VIEW usv_BooksWithAuthors
AS
SELECT
    B.Id AS BookId,
    B.Name AS BookName,
    B.PageCount,
    CONCAT(A.Name, ' ', A.Surname) AS AuthorFullName
FROM Books B
INNER JOIN Authors A ON B.AuthorId = A.Id

Create Procedure usp_GetAllDataBySearch
@search nvarchar(50)
As
Begin
		Select BookId,BookName,PageCount,AuthorFullName From usv_BooksWithAuthors where AuthorFullName  Like '%s@search%s' OR BookName  Like '%s@search%s'
End

CREATE VIEW AuthorSummary 
AS
SELECT
    A.Id AS AuthorId,
    CONCAT(A.Name, ' ', A.Surname) AS FullName,
    COUNT(B.Id) AS BooksCount,
    MAX(B.PageCount) AS MaxPageCount
FROM
    Authors A
	JOIN
    Books B ON A.Id = B.AuthorId
GROUP BY
    A.Id, A.Name, A.Surname;



Alter Procedure usp_GetAllDataBySearch
@search nvarchar(50)
As
Begin
		Select BookId,BookName,PageCount,AuthorFullName From usv_BooksWithAuthors where AuthorFullName  Like '%@search%' Or BookName Like '%@search%'
End



exec usp_GetAllDataBySearch 'Lee'

Create Table AuthorsArchive
(
	Id int,
	Name nvarchar(50),
	SurName nvarchar(50),
	OperationType nvarchar(100),
	OperationDate DateTime2
)

Create Trigger AuthorArchiveData
on Authors
after insert
As
Begin
	declare @id int
	declare @name nvarchar(50)
	declare @surname nvarchar(50)

	select @id = obj.Id from inserted obj
	select @name = obj.Name from inserted obj
	select @surname = obj.SurName from inserted obj

	insert into AuthorsArchive(Id,Name,Surname,OperationType,OperationDate)
	values
	(@id,@name,@surname,'Insert',GETDATE())
End




Alter Trigger AuthorsArchiveData
on Authors
after delete
As
Begin
	declare @id int
	declare @name nvarchar(50)
	declare @surname nvarchar(50)

	select @id = obj.Id from deleted obj
	select @name = obj.Name from deleted obj
	select @surname = obj.Surname from deleted obj

	insert into AuthorsArchive
	values
	(@id,@name,@surname,'Delete',GETDATE())
End

Alter Trigger AuthorsArchiveData
on Authors
after Update
As
Begin
	declare @id int
	declare @name nvarchar(50)
	declare @surname nvarchar(50)

	select @id = obj.Id from inserted obj
	select @name = obj.Name from inserted obj
	select @surname = obj.Surname from inserted obj

	insert into AuthorsArchive
	values
	(@id,@name,@surname,'Update',GETDATE())
End




	
