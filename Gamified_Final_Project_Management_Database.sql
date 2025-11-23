--GAMIFIED PROJECT MANAGEMENT SYSTEM
--Create database
CREATE DATABASE ProjectManagementDataBase;

--Create Tables for Using Entities
--USERS table
CREATE TABLE USERS (
    P_User_Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,	--id number and primary key for users table
    Username NVARCHAR(50) NOT NULL UNIQUE,				--user name used in the system
	Firstname NVARCHAR(100) NOT NULL,					--legal firstname
	Lastname NVARCHAR(100) NOT NULL,					--legal lastname
	Phone NVARCHAR(20) NULL,							--phone number
    Email NVARCHAR(100) NOT NULL UNIQUE,				--email info
    Password_Hash NVARCHAR(256) NOT NULL,				--the shadow of the password stored in the system for data security
    Registration_DATE DATETIME DEFAULT GETDATE(),		--the date the account was created
    Avatar_Url NVARCHAR(255) NULL,						--the profile photo used in the system
	User_Level INT DEFAULT 1,							--user's level (increases as the task is completed and the project is completed)
	Total_Experience INT DEFAULT 0,						--user's total scores
	Current_Experience INT DEFAULT 0,					--user's current scores
	Last_Activity_Date DATETIME,						--last login time
);
--TEAMS table
CREATE TABLE TEAMS (
    Team_Id INT PRIMARY KEY IDENTITY(1,1),					--id number and primary key for teams table
    Team_Name NVARCHAR(50) NOT NULL,						--name of team
    Creation_Date DATETIME DEFAULT GETDATE(),				--the date the team was created
    Leader_User_Id INT NULL,								--id number of team leader
   
   CONSTRAINT FK_TEAMS_USERS FOREIGN KEY (Leader_User_Id)	--If the user who is the team leader is deleted from the system
    REFERENCES USERS(P_User_Id) ON DELETE SET NULL			--the Leader_User_Id field in the TEAMS table is made NULL
															--the team is not deleted, only the leader information is removed
);
--TEAM MEMBERS table    -- Her kullanýcý birden fazla takýmda olabilir, ama ayný takýmda yalnýzca bir kez yer alabilir.

CREATE TABLE TEAMMEMBERS (
    Member_Id INT PRIMARY KEY IDENTITY(1,1),				--id number and primary key for teams table
    Team_Id INT NOT NULL,									--which group are the members in
    P_User_Id INT NOT NULL,									--which users are the members
    Join_Date DATETIME DEFAULT GETDATE(),					--time of being a team member
    ROLE NVARCHAR(50) NULL,									--the role in the team(such as project manager,QA Engineer, Scrum Master)
    CONSTRAINT FK_TEAMMEMBERS_TEAMS FOREIGN KEY (Team_Id)	--If a TEAMS is deleted, all TEAMMEMBERS connected to 
    REFERENCES TEAMS(Team_Id) ON DELETE CASCADE,			--that team are also automatically deleted.
    CONSTRAINT FK_TEAMMEMBERS_USERS FOREIGN KEY (P_User_Id)	--If a user (USERS) is deleted, all team memberships of that
    REFERENCES USERS(P_User_Id) ON DELETE CASCADE,			-- user are also deleted.
    CONSTRAINT UQ_TEAM_MEMBER UNIQUE (Team_Id, P_User_Id)	--The same user can join the same team only once.
															--the combination Team_Id + P_User_Id must be unique.
);
--PROJECT CATEGORIES table
CREATE TABLE PROJECT_CATEGORIES (
    Category_Id INT PRIMARY KEY IDENTITY(1,1),	--id number and primary key for project categories table
    Category_Name NVARCHAR(50) NOT NULL			--There are 10 categories in this system, 
	CHECK (Category_Name IN (					--and each project must be belong these categories
	'Software & Application Development',		--if any project belongs different from categories it is system error
	'Marketing & Advertising',					--Every project necessarily belongs to a category
	'Data & Analytics',					
	'Research & Development (R&D)',
	'Customer Service & Support',
	'Training & Documentation',
	'Operations & Process Improvement', 
	'IT Infrastructure & Technology Management',
	'Event Planning & Organization'
	)),	
    Category_Description NVARCHAR(200) NULL		--description of category
);
--PROJECTS Table
CREATE TABLE PROJECTS (
    Project_Id INT PRIMARY KEY IDENTITY(1,1),											--id number and primary key for projects table
    Project_Name NVARCHAR(100) NOT NULL,												--Name of Project
    Project_Description NVARCHAR(500) NULL,												--Additional info for project
    Starting_Date DATETIME DEFAULT GETDATE(),											--It defines the start time
    Deadline DATETIME NOT NULL,															--It defines deadline,it is necessary to managing process,not null. 
    Project_Status NVARCHAR(20) NOT NULL												--Indicates the status of the project,no blank can be passed. 
    CHECK (Project_Status IN ('Not Started', 'In Progress', 'Completed', 'On Hold')),	--and no value can be entered other than the defined values.
    Team_Id INT NOT NULL,																-- which team responsible(foreign key)
    Category_Id INT NULL,																--which category defines the project(foreign_key)
    CONSTRAINT FK_PROJECTS_TEAMS FOREIGN KEY (Team_Id)									--Each project has to be assigned to a team
    REFERENCES TEAMS(Team_Id) ON DELETE CASCADE,										--If the team is deleted,the projects belonging to  
																						--this team are also deleted automatically
	CONSTRAINT FK_PROJECTS_CATEGORIES FOREIGN KEY (Category_Id)							--If the category is deleted, the category ID of the projects 
	REFERENCES PROJECT_CATEGORIES(Category_Id) ON DELETE SET NULL						--in this category is set to NULL, the project is not deleted   
);
--TASKS table
CREATE TABLE TASKS (
    Task_Id INT PRIMARY KEY IDENTITY(1,1),								--id number and primary key for tasks table
    Task_Name NVARCHAR(100) NOT NULL,									--name of the task
    Task_Description NVARCHAR(500) NULL,								--description of task
    Task_Status NVARCHAR(20) NOT NULL									--It defines the progress of the task process
    CHECK (Task_Status IN ('To Do', 'In Progress', 'Done', 'Blocked')),	--The value must be these words and it can't be null values
    Task_Priority NVARCHAR(10) NOT NULL									--It defines to priority based on importance or emergency level
    CHECK (Task_Priority IN ('Low', 'Medium', 'High', 'Critical')),		--The values have to be these words and not null
    Creation_Date DATETIME DEFAULT GETDATE(),							--Creation_Date is it's time for the task to be created
    Due_Date DATETIME NULL,												--The end date of the task
    Project_Id INT NOT NULL,											--The project to which the task belongs
    Assigned_User_Id INT NULL,											--The user to whom the task is assigned
    CONSTRAINT FK_TASKS_PROJECTS FOREIGN KEY (Project_Id)				--If the project is deleted, all tasks are deleted automatically 
    REFERENCES PROJECTS(Project_Id) ON DELETE CASCADE,					--Relationship between Projects table and Tasks table with Foreign key
    CONSTRAINT FK_TASKS_USERS FOREIGN KEY (Assigned_User_Id)			--If the user is deleted, the task remains unclaimed,not deleted
    REFERENCES USERS(P_User_Id) ON DELETE SET NULL						--There may be tasks that are not assigned
);
--TASK REWARDS table
CREATE TABLE TASK_REWARDS (
    Reward_Id INT PRIMARY KEY IDENTITY(1,1),							--id number and primary key for task rewards table
    Task_Id INT NOT NULL UNIQUE,										--Every reward must be connected to a task and it must be unique(1:1 relationship)
    Base_Experience INT NOT NULL,										--Basic experience points to be earned when completing the task(not null)
    Bonus_Experience INT NULL,											--Bonus experience that can be given for extra performance(optionall,can be null)
    CONSTRAINT FK_TASK_REWARDS_TASKS FOREIGN KEY (Task_Id)				--If the task is deleted, the reward record is also automatically deleted
    REFERENCES TASKS(Task_Id) ON DELETE CASCADE							--protects data integrity and prevents the occurrence of unclaimed records
																		--sahipsiz kayýt engelleme
);
--GAMIFICATION table
CREATE TABLE GAMIFICATION (							
    Achievement_Id INT PRIMARY KEY IDENTITY(1,1),	--id number and primary key for gamification table
    Achievement_Name NVARCHAR(50) NOT NULL,			--The name of achievement is such as "First Project", "Perfect Completion"
    Achievement_Description NVARCHAR(200) NULL,		--Additional description for achievement(optional)
    Experience_Reward INT NOT NULL,					--Experience points to be awarded when achievement is won (XP)
    Badge_Image_Url NVARCHAR(255) NULL				--The visual path of the achievement badge such as congratulations gif url
);
--USER ACHIEVEMENTS table
CREATE TABLE USER_ACHIEVEMENTS (
    User_Achievement_Id INT PRIMARY KEY IDENTITY(1,1),							--id number and primary key for User Achievements table
    P_User_Id INT NOT NULL,														--who won the achievement(reference-foreign key)
    Achievement_Id INT NOT NULL,												--what has been achieved(reference-foreign key)
    Unlock_Date DATETIME DEFAULT GETDATE(),										--date/time of acquisition for achievement
    CONSTRAINT FK_USER_ACHIEVEMENTS_USERS FOREIGN KEY (P_User_Id)				--If the user is deleted,
    REFERENCES USERS(P_User_Id) ON DELETE CASCADE,								--all his achievements are also deleted
    CONSTRAINT FK_USER_ACHIEVEMENTS_GAMIFICATION FOREIGN KEY (Achievement_Id)	--If the Achievement_Id is deleted,
    REFERENCES GAMIFICATION(Achievement_Id) ON DELETE CASCADE,					--all user records are also deleted
    CONSTRAINT UQ_USER_ACHIEVEMENT UNIQUE (P_User_Id, Achievement_Id)			--Prevents the same user from gaining the same success again
																				--A user can earn a certain achievement only once, 
																				--there is no data repetition
);
--PROJECT FILES table
CREATE TABLE PROJECT_FILES (
    Project_File_Id INT PRIMARY KEY IDENTITY(1,1),						--id number and primary key for Project files table
    Project_File_Name NVARCHAR(255) NOT NULL,							--file name
    Project_File_Path NVARCHAR(500) NOT NULL,							--The storage path of the file on the server
    Upload_Date DATETIME DEFAULT GETDATE(),								--File upload date and time
    Project_Id INT NOT NULL,											--The project to which the file belongs based on project table(foreign key)
    Uploaded_By_User_Id INT NULL,										--The user who uploaded the file based on user table(foreign key)
    File_Size BIGINT NULL,												--file size
    File_Type NVARCHAR(50) NULL,										--file type such as pdf,csv,excel,docx
    CONSTRAINT FK_PROJECT_FILES_PROJECTS FOREIGN KEY (Project_Id)		--If the project is deleted, all files are also deleted
    REFERENCES PROJECTS(Project_Id) ON DELETE CASCADE,					
    CONSTRAINT FK_PROJECT_FILES_USERS FOREIGN KEY (Uploaded_By_User_Id) --If the user is deleted, the file remains unclaimed,it is not deleted.
    REFERENCES USERS(P_User_Id) ON DELETE SET NULL
);
--COMMENTS table
CREATE TABLE COMMENTS (
    Comment_Id INT PRIMARY KEY IDENTITY(1,1),			--id number and primary key for comments table
    Content NVARCHAR(1000) NOT NULL,					--Comment text
    Creation_Date DATETIME DEFAULT GETDATE(),			--Date and time of creation of the comment
    P_User_Id INT NOT NULL,								--The user who made the comment
    Task_Id INT NOT NULL,								--The task for which the comment was made
    CONSTRAINT FK_COMMENTS_USERS FOREIGN KEY (P_User_Id)--If the user tries to delete, it gives an error  
    REFERENCES USERS(P_User_Id) ON DELETE NO ACTION,	--(comments must be deleted first)
    CONSTRAINT FK_COMMENTS_TASKS FOREIGN KEY (Task_Id)	-- If the task is deleted, all comments will also be deleted
    REFERENCES TASKS(Task_Id) ON DELETE CASCADE			
);
--NOTIFICATION table
CREATE TABLE NOTIFICATION (
    Notification_Id INT PRIMARY KEY IDENTITY(1,1),			--id number and primary key for notification table
    Notification_Message NVARCHAR(500) NOT NULL,			--Notification message content,There can be no empty notification
    Is_Read BIT DEFAULT 0,									--Whether the notification has been read or not,if not it's default 0
    Notification_Date DATETIME DEFAULT GETDATE(),			--Date and time of creation of the notification
    P_User_Id INT NOT NULL,									--The user to whom the notification was sent
    CONSTRAINT FK_NOTIFICATION_USERS FOREIGN KEY (P_User_Id)--If the user is deleted, all their notifications are also deleted
    REFERENCES USERS(P_User_Id) ON DELETE CASCADE
);
--ADDING ROWS PART TO TRY 
-- Insert into USERS
INSERT INTO USERS (Username, Firstname, Lastname, Phone, Email, Password_Hash, Avatar_Url, User_Level, Total_Experience, Current_Experience, Last_Activity_Date)
VALUES 
('johndoe', 'John', 'Doe', '555-123-4567', 'john.doe@example.com', 'hashedpassword123', '', 1, 0, 0, '2023-01-15 09:30:00'),
('janedoe', 'Jane', 'Doe', '555-234-5678', 'jane.doe@example.com', 'hashedpassword234', '', 2, 100, 50, '2023-01-16 10:15:00'),
('bobsmith', 'Bob', 'Smith', '555-345-6789', 'bob.smith@example.com', 'hashedpassword345', '', 3, 250, 100, '2023-01-17 11:45:00'),
('alicej', 'Alice', 'Johnson', '555-456-7890', 'alice.j@example.com', 'hashedpassword456', '', 1, 0, 0, '2023-01-18 08:20:00'),
('mikeb', 'Mike', 'Brown', '555-567-8901', 'mike.b@example.com', 'hashedpassword567', '', 2, 150, 75, '2023-01-19 14:30:00');

-- Insert into TEAMS
INSERT INTO TEAMS (Team_Name, Leader_User_Id)
VALUES 
('Development Team', 1),
('Marketing Team', 2),
('Data Analytics', 3),
('Customer Support', 4),
('Research Team', 5);

-- Insert into TEAMMEMBERS
INSERT INTO TEAMMEMBERS (Team_Id, P_User_Id, ROLE)
VALUES 
(1, 1, 'Team Lead'),
(1, 2, 'Developer'),
(2, 2, 'Marketing Manager'),
(3, 3, 'Data Scientist'),
(4, 4, 'Support Lead'),
(5, 5, 'Researcher'),
(2, 3, 'Content Writer'),
(3, 4, 'Data Analyst'),
(4, 5, 'Support Agent'),
(5, 1, 'Research Assistant');

-- Insert into PROJECT_CATEGORIES
INSERT INTO PROJECT_CATEGORIES (Category_Name, Category_Description)
VALUES 
('Software & Application Development', 'Projects related to software creation and app development'),
('Marketing & Advertising', 'Promotional campaigns and advertising projects'),
('Data & Analytics', 'Data processing and analysis projects'),
('Research & Development (R&D)', 'Innovation and experimental projects'),
('Customer Service & Support', 'Projects improving customer support systems');

-- Insert into PROJECTS
INSERT INTO PROJECTS (Project_Name, Project_Description, Starting_Date, Deadline, Project_Status, Team_Id, Category_Id)
VALUES 
('Website Redesign', 'Complete overhaul of company website', '2023-01-01', '2023-03-01', 'In Progress', 1, 1),
('Social Media Campaign', 'Q2 social media marketing push', '2023-02-01', '2023-04-15', 'Not Started', 2, 2),
('Customer Data Analysis', 'Analyze customer behavior patterns', '2023-01-15', '2023-02-28', 'In Progress', 3, 3),
('New Product Research', 'Market research for upcoming product', '2023-03-01', '2023-05-30', 'Not Started', 5, 4),
('Support Portal Upgrade', 'Improve customer support portal', '2023-02-10', '2023-03-31', 'On Hold', 4, 5);

-- Insert into TASKS
INSERT INTO TASKS (Task_Name, Task_Description, Task_Status, Task_Priority, Creation_Date, Due_Date, Project_Id, Assigned_User_Id)
VALUES 
('Design Homepage', 'Create new homepage layout', 'In Progress', 'High', '2023-01-02', '2023-01-20', 1, 1),
('Write Campaign Copy', 'Draft social media posts', 'To Do', 'Medium', '2023-02-01', '2023-02-10', 2, 2),
('Clean Dataset', 'Prepare data for analysis', 'Done', 'Low', '2023-01-16', '2023-01-25', 3, 3),
('Survey Design', 'Create customer survey', 'Blocked', 'Medium', '2023-03-01', '2023-03-15', 4, 5),
('Portal Testing', 'Test new support features', 'To Do', 'Critical', '2023-02-12', '2023-03-01', 5, 4);

-- Insert into TASK_REWARDS
INSERT INTO TASK_REWARDS (Task_Id, Base_Experience, Bonus_Experience)
VALUES 
(1, 50, 10),
(2, 30, 5),
(3, 40, NULL),
(4, 35, 15),
(5, 60, 20);

-- Insert into GAMIFICATION
INSERT INTO GAMIFICATION (Achievement_Name, Achievement_Description, Experience_Reward, Badge_Image_Url)
VALUES 
('First Task', 'Completed your first task', 25, ''),
('Team Player', 'Joined your first team', 50, ''),
('Project Champion', 'Led a project to completion', 100, ''),
('Task Master', 'Completed 10 tasks', 75, ''),
('Early Bird', 'Completed a task before deadline', 30, '');

-- Insert into USER_ACHIEVEMENTS
INSERT INTO USER_ACHIEVEMENTS (P_User_Id, Achievement_Id, Unlock_Date)
VALUES 
(1, 1, '2023-01-05'),
(2, 1, '2023-01-06'),
(2, 2, '2023-01-07'),
(3, 1, '2023-01-08'),
(4, 1, '2023-01-09');

-- Insert into PROJECT_FILES
INSERT INTO PROJECT_FILES (Project_File_Name, Project_File_Path, Upload_Date, Project_Id, Uploaded_By_User_Id, File_Size, File_Type)
VALUES 
('design_specs.pdf', '/projects/1/files/design.pdf', '2023-01-03', 1, 1, 1024, 'PDF'),
('campaign_brief.docx', '/projects/2/files/brief.docx', '2023-02-02', 2, 2, 512, 'DOCX'),
('raw_data.csv', '/projects/3/files/data.csv', '2023-01-17', 3, 3, 2048, 'CSV'),
('research_plan.pdf', '/projects/4/files/plan.pdf', '2023-03-02', 4, 5, 1536, 'PDF'),
('test_cases.xlsx', '/projects/5/files/tests.xlsx', '2023-02-13', 5, 4, 768, 'XLSX');

-- Insert into COMMENTS
INSERT INTO COMMENTS (Content, Creation_Date, P_User_Id, Task_Id)
VALUES 
('The design looks great!', '2023-01-04', 2, 1),
('Need more details on target audience', '2023-02-03', 1, 2),
('Data cleaning complete', '2023-01-20', 3, 3),
('Waiting for approval to proceed', '2023-03-03', 5, 4),
('Found a bug in the test cases', '2023-02-14', 4, 5);

-- Insert into NOTIFICATION
INSERT INTO NOTIFICATION (Notification_Message, Is_Read, Notification_Date, P_User_Id)
VALUES 
('Your task "Design Homepage" is due soon', 0, '2023-01-18', 1),
('You have been assigned to a new team', 1, '2023-01-08', 2),
('New comment on your task', 0, '2023-01-21', 3),
('Project deadline approaching', 0, '2023-03-25', 5),
('Task completed successfully', 1, '2023-02-15', 4);

--CONTROLLING PART  WITH USING SELECT
-- USERS table
SELECT * FROM USERS;

-- TEAMS table
SELECT * FROM TEAMS;

-- TEAMMEMBERS table
SELECT * FROM TEAMMEMBERS;

-- PROJECT_CATEGORIES table
SELECT * FROM PROJECT_CATEGORIES;

-- PROJECTS table
SELECT * FROM PROJECTS;

-- TASKS table
SELECT * FROM TASKS;

-- TASK_REWARDS table
SELECT * FROM TASK_REWARDS;

-- GAMIFICATION table
SELECT * FROM GAMIFICATION;

-- USER_ACHIEVEMENTS table
SELECT * FROM USER_ACHIEVEMENTS;

-- PROJECT_FILES table
SELECT * FROM PROJECT_FILES;

-- COMMENTS table
SELECT * FROM COMMENTS;

-- NOTIFICATION table
SELECT * FROM NOTIFICATION;

--I deleted the records that I added extra
--SELECT * FROM TEAMMEMBERS WHERE Member_Id > 5;
--DELETE FROM TEAMMEMBERS WHERE Member_Id > 5;
UPDATE TASKS				--Change and assign task to new user
SET Assigned_User_Id = 2
WHERE Task_Id = 3;

SELECT						-- sorting users with levels based on total experience (max from min)
    Username,
    User_Level,
    Total_Experience
FROM USERS
ORDER BY Total_Experience DESC

SELECT											--counting to which team has how many user
    T.Team_Name,
    COUNT(TM.P_User_Id) AS Member_Count
FROM TEAMS T
JOIN TEAMMEMBERS TM ON T.Team_Id = TM.Team_Id
GROUP BY T.Team_Name;

SELECT						--who has maximum experience
    u.Username,
    u.Total_Experience
FROM USERS u
WHERE u.Total_Experience = (SELECT MAX(Total_Experience) FROM USERS);

--Triggers
CREATE TRIGGER trg_UpdateUserXP
ON TASKS
AFTER UPDATE
AS
BEGIN
    UPDATE USERS
    SET Total_Experience = Total_Experience + TR.Base_Experience + ISNULL(TR.Bonus_Experience, 0),
        Current_Experience = Current_Experience + TR.Base_Experience + ISNULL(TR.Bonus_Experience, 0)
    FROM USERS U
    JOIN TASKS T ON U.P_User_Id = T.Assigned_User_Id
    JOIN TASK_REWARDS TR ON T.Task_Id = TR.Task_Id
    WHERE T.Task_Status = 'Done' AND T.Task_Id IN (SELECT Task_Id FROM inserted);
END;

UPDATE TASKS	--testing to trigger
SET Task_Status = 'Done'
WHERE Task_Id = 1;

SELECT Username, Total_Experience, Current_Experience --controlling to  trigger results
FROM USERS
WHERE P_User_Id = (
    SELECT Assigned_User_Id FROM TASKS WHERE Task_Id = 1
);

