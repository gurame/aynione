CREATE TABLE User (
    Userid              int not null AUTO_INCREMENT,
    Email        varchar(64) not null,
    Password_hash   varchar(128) not null,
    PRIMARY KEY (Userid),
    CONSTRAINT UK_User_Email UNIQUE (Email)
);

CREATE TABLE Runa (
    RunaId          INT            NOT NULL AUTO_INCREMENT,
    Name            VARCHAR (128)  NOT NULL,
    Email           VARCHAR (256)  NULL,
    Alias           VARCHAR (2048) NULL,
    Description     VARCHAR (2048) NULL,
    ProfileImageUrl VARCHAR (2000) NULL,
    PRIMARY KEY (RunaId),
    CONSTRAINT UK_Runa_Email UNIQUE (Email),
    CONSTRAINT UK_Runa_Name  UNIQUE (Name)
);

CREATE TABLE Ayllu (
    AylluId         INT            NOT NULL AUTO_INCREMENT,
    Name            VARCHAR (128)  NOT NULL,
    Email           VARCHAR (256)  NULL,
    Alias           VARCHAR (2048) NULL,
    Description     VARCHAR (2048) NULL,
    ProfileImageUrl VARCHAR (2000) NULL,
    PRIMARY KEY (AylluId),
    CONSTRAINT UK_Ayllu_Email UNIQUE (Email),
    CONSTRAINT UK_Ayllu_Name  UNIQUE (Name)
);

CREATE TABLE Huaca (
    HuacaId          INT            NOT NULL AUTO_INCREMENT,
    Name            VARCHAR (128)  NOT NULL,
    Alias           VARCHAR (2048) NULL,
    Description     VARCHAR (2048) NULL,
    ProfileImageUrl VARCHAR (2000) NULL,
    PRIMARY KEY (HuacaId),
    CONSTRAINT UK_Huaca_Name  UNIQUE (Name)
);

CREATE TABLE AylluRuna (
    AylluId INT NOT NULL,
    RunaId  INT NOT NULL,
    PRIMARY KEY (AylluId, RunaId)
);

ALTER TABLE AylluRuna
ADD CONSTRAINT FK_AylluRuna_AylluId
FOREIGN KEY (AylluId) REFERENCES Ayllu(AylluId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE AylluRuna
ADD CONSTRAINT FK_AylluRuna_RunaId
FOREIGN KEY (RunaId) REFERENCES Runa(RunaId) ON DELETE CASCADE ON UPDATE CASCADE;


CREATE TABLE HuacaAyllu (
    HuacaId INT NOT NULL,
    AylluId  INT NOT NULL,
    PRIMARY KEY (HuacaId, AylluId)
);

ALTER TABLE HuacaAyllu
ADD CONSTRAINT FK_HuacaAyllu_HuacaId
FOREIGN KEY (HuacaId) REFERENCES Huaca(HuacaId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE HuacaAyllu
ADD CONSTRAINT FK_HuacaAyllu_AylluId
FOREIGN KEY (AylluId) REFERENCES Ayllu(AylluId) ON DELETE CASCADE ON UPDATE CASCADE;

create table Tambo
(
    TamboId         INT NOT NULL AUTO_INCREMENT,
    Name            varchar(128) not null,
    Description     varchar(1024) null,
	DynFunction     varchar(4000) null,
	ProfileImageUrl VARCHAR (2000) NULL,
	PRIMARY KEY (TamboId),
    CONSTRAINT UK_Tambo_Name  UNIQUE (Name)
);

create table Quipu (
    QuipuId     int not null AUTO_INCREMENT,
    Name        varchar(512) not null,
    Tambo       varchar(256) not null,
    Runa        varchar(128),
    Huaca        varchar(128) not null,
    Status      varchar(128) not null,
    Url         varchar(3000),
    Data        varchar(4000),
    Description varchar(1024),
    CreatedOn   datetime not null,
    RegisterOn  datetime not null default now(),
    Processed   bit default 0 not null,
    PRIMARY KEY (QuipuId)
);

create table QuipuIssue (
    QuipuIssueId int not null AUTO_INCREMENT,
    QuipuId int not null,
    Message varchar(3000) not null,
    PRIMARY KEY (QuipuIssueId)
);

ALTER TABLE QuipuIssue
ADD CONSTRAINT FK_QuipuIssue_QuipuIs
FOREIGN KEY (QuipuId) REFERENCES Quipu(QuipuId) ON DELETE CASCADE ON UPDATE CASCADE;

create table Quri(
    QuriId int not null AUTO_INCREMENT,
    Score decimal(5,3) not null,
    QuipuId int not null,
    NameId int not null,
    TamboId int not null,
    HuacaId int not null,
    RunaId int not null,
    Primary key (QuriId)
);

create table QuipuName(
    nameid int not null AUTO_INCREMENT,
    name varchar(512),
    primary key (nameid)
);

CREATE INDEX  idx_quri_huacaid on Quri(huacaid);
CREATE INDEX  idx_quri_runaid on Quri(runaid);


ALTER TABLE Quri ADD CONSTRAINT FK_Quri_QuipuId
    FOREIGN KEY (QuipuId) REFERENCES Quipu(QuipuId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Quri ADD CONSTRAINT FK_Quri_TamboId
    FOREIGN KEY (TamboId) REFERENCES Tambo(TamboId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Quri ADD CONSTRAINT FK_Quri_HuacaId
    FOREIGN KEY (HuacaId) REFERENCES Huaca(HuacaId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Quri ADD CONSTRAINT FK_Quri_RunaId
    FOREIGN KEY (RunaId) REFERENCES Runa(RunaId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE QURI ADD CONSTRAINT FK_Quri_NameId
    FOREIGN KEY (NameId) REFERENCES QuipuName(NameId) ON DELETE CASCADE ON UPDATE CASCADE;


create table Kancha(
    TamboId int not null,
    HuacaId int not null,
    RunaId int not null,
    NameId int not null,
    QuipuId int not null,
    Score decimal(5,3) not null,
    primary key (TamboId, HuacaId, RunaId, NameId, QuipuId)
);

ALTER TABLE Kancha ADD CONSTRAINT FK_Kancha_QuipuId
    FOREIGN KEY (QuipuId) REFERENCES Quipu(QuipuId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Kancha ADD CONSTRAINT FK_Kancha_TamboId
    FOREIGN KEY (TamboId) REFERENCES Tambo(TamboId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Kancha ADD CONSTRAINT FK_Kancha_HuacaId
    FOREIGN KEY (HuacaId) REFERENCES Huaca(HuacaId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Kancha ADD CONSTRAINT FK_Kancha_RunaId
    FOREIGN KEY (RunaId) REFERENCES Runa(RunaId) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Kancha ADD CONSTRAINT FK_Kancha_NameId
    FOREIGN KEY (NameId) REFERENCES QuipuName(NameId) ON DELETE CASCADE ON UPDATE CASCADE;


/*STORE PROCEDURE SECTION*/
DELIMITER $$

/* ===================================== Kancha ================ */
create procedure usp_rumi_list()
begin
    select K.QuipuId, K.NameId, QN.name, Q.createdon, K.Score, count(K.runaid) as runa_count, K.TamboId, K.HuacaId
    from kancha K join QuipuName QN on K.nameid = QN.nameid
         join Quipu Q on K.quipuid = Q.quipuid
    group by K.runaid;
end;

$$
create procedure usp_rumi_detail_by_quipuid(in pquipuid int)
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        select K.QuipuId, K.NameId, QN.name, Q.createdon, K.Score, count(K.runaid) as runa_count, K.HuacaId, K.TamboId,
             T.name as tambo_name,
             T.dynfunction,
             T.ProfileImageUrl as tambo_profile_url,
             H.name as huaca_name,
             H.ProfileImageUrl as huaca_profile_url
        from kancha K join QuipuName QN on K.nameid = QN.nameid
             join Quipu Q on K.quipuid = Q.quipuid
             join Tambo T on K.tamboid = T.tamboid
             join Huaca H on K.huacaid = H.huacaid
        where K.QuipuId = pquipuid
        group by K.runaid;

        select K.QuipuId, K.TamboId, K.HuacaId, K.RunaId, K.NameId, QN.name, K.Score, Q.createdon,
               R.name as runa_name,
               R.ProfileImageUrl as runa_profile_url
        from kancha K join QuipuName QN on K.nameid = QN.nameid
             join Quipu Q on K.quipuid = Q.quipuid
             join Runa R on K.runaid = R.runaid
        where K.QuipuId = pquipuid
        order by K.runaid;
    COMMIT;

end;
$$

/*====================================== QURI ===================================*/

create procedure usp_quri_detail_from_kancha()
begin
    set @pquipuid = -1;
    set @pnextquipuid = -1;
    select quipuid from Kancha order by quipuid desc limit 1 into @pquipuid;

    select quipuid from Quipu where quipuid > @pquipuid
		order by quipuid asc limit 1 into @pnextquipuid;

    select quriid, quipuid, score, tamboid, huacaid, runaid, nameid
    from Quri where quipuid = @pnextquipuid order by quriid asc;
end;
$$
create procedure usp_ayni_kancha_delete(
    in ptamboid int,
    in phuacaid int,
    in pnameid int
)
begin
    delete from  Kancha where tamboid = ptamboid and huacaid = phuacaid and nameid = pnameid;
end;
$$
create procedure usp_ayni_kancha_create(
    in pscore decimal(5,3),
    in pquipuid int,
    in pnameid int,
    in ptamboid int,
    in phuacaid int,
    in prunaid int
)
begin
    insert into Kancha(score, quipuid, nameid, tamboid, huacaid, runaid)
    values ( pscore, pquipuid, pnameid, ptamboid, phuacaid , prunaid);
end;

$$
create procedure usp_quri_list()
begin
    select quriid, quipuid, score, tamboid, huacaid, runaid, nameid
    from Quri;
end;
$$

create procedure usp_quri_list_quipuid(
    in pquipuid int
)
begin
    select quriid, quipuid, score, tamboid, huacaid, runaid, nameid
    from Quri where quipuid = pquipuid;
end;
$$

create procedure usp_quri_list_tamboid(
    in ptamboid int
)
begin
    select quriid, quipuid, score, tamboid, huacaid, runaid, nameid
    from Quri where tamboid = ptamboid;
end;
$$
create procedure usp_quri_list_runaid(
    in prunaid int
)
begin
    select quriid, quipuid, score, tamboid, huacaid, runaid, nameid
    from Quri where runaid = prunaid;
end;

$$

create procedure usp_quri_list_huacaid(
    in phuacaid int
)
begin
    select quriid, quipuid, score, tamboid, huacaid, runaid, nameid
    from Quri where huacaid = phuacaid;
end;

$$

create procedure usp_quri_list_aylluid(
    in paylluid int
)
begin
    select Q.quriid, Q.quipuid, Q.score, Q.tamboid, Q.huacaid, Q.runaid, Q.nameid
    from   Ayllu A join AylluRuna AR on A.AylluId = AR.AylluId
           join Quri Q on AR.RunaId = Q.RunaId
    where A.aylluid = paylluid;
end;

$$
create procedure usp_quri_create(
    in pscore decimal(5,3),
    in pquipuid int,
    in pname varchar(512),
    in ptamboid int,
    in phuacaid int,
    in prunaid int
)
begin
    insert into QuipuName (name)
    select * from (select pname) as tmp
    where not exists (select name from QuipuName where name=pname) limit 1;

    SELECT @nameid := nameid from QuipuName where name = pname;

    insert into Quri (score, quipuid, nameid, tamboid, huacaid, runaid)
        values (pscore, pquipuid, @nameid, ptamboid, phuacaid, prunaid);
    SELECT LAST_INSERT_ID();

end;
$$

/*=========================QUIPU===================================*/
create procedure usp_quipu_issue_create(
    in pquipuid int,
    in pmessage varchar(3000)
)
begin
    insert into QuipuIssue (quipuid, message) values (pquipuid, pmessage);
    SELECT LAST_INSERT_ID();
end;
$$
create procedure usp_quipu_processed(
    in pquipuid int
)
begin
    update Quipu
    set processed = 1
    where quipuid = pquipuid;
end;
$$
create procedure usp_quipu_create (
    in pname varchar(512) ,
    in ptambo varchar(256),
    in phuaca varchar(128),
    in pstatus varchar(128),
    in pruna varchar(128),
    in purl varchar(3000),
    in pdata varchar(4000),
    in pdescription varchar(1024),
    in pcreatedon datetime,
    in pregisteron datetime
    )
 begin
    insert into QUIPU (name, tambo, huaca, status, runa, url, data, description, createdon, registeron )
    values (pname, ptambo, phuaca, pstatus, pruna, purl, pdata, pdescription, pcreatedon, pregisteron);
    SELECT LAST_INSERT_ID();
 end;
 $$
 create procedure usp_quipu_get (IN pquipuid int)
 begin
    select quipuid, name, tambo, huaca, status, runa, url, data, description, createdon, registeron
    from QUIPU
    where quipuid = pquipuid;
 end
 $$
 create procedure usp_quipu_unprocessed()
 begin
    select quipuid, name, tambo, huaca, status, runa, url, data, description, createdon, registeron, processed
    from QUIPU
    where processed = 0 LIMIT 1;
 end
 $$
/*=========================USER ===================================*/

create procedure usp_user_create( IN pemail varchar(64) , in ppassword varchar(128))
begin
    insert into User (Email, Password_hash) values (pemail, ppassword);
    SELECT LAST_INSERT_ID();
end;
$$
create procedure usp_user_byid( IN pemail varchar(64))
begin
    select Userid, Email, Password_hash from User where Email = pemail;
end;
$$

/*=========================RUNA ===================================*/

create procedure usp_runa_create(
    IN name varchar(128),
    IN pprofileimageurl varchar(2000))
begin
    INSERT INTO Runa (Name, ProfileImageUrl) values(name, pprofileimageurl);
    SELECT LAST_INSERT_ID();
end;
$$
create procedure usp_runa_update(
    IN prunaid int,
    IN pname varchar(128),
    IN pemail varchar(256),
    IN palias VARCHAR (2048),
    IN pdescription varchar(2048),
    IN pprofileimageurl varchar(2000)
    )
begin
    update Runa
    set Name = pname, Email = pemail, Description = pdescription,
        ProfileImageUrl = pprofileimageurl, alias = palias
    where RunaId = prunaid;
end;

$$

create procedure usp_runa_delete(IN runaid int)
begin
    delete from Runa where RunaId = runaid;
end;

$$
create procedure usp_runa_detail_view_byid( IN prunaid int)
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    select R.RunaId, R.Name, R.Email, R.Alias, R.Description, R.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Runa R left join Kancha K on R.RunaId = K.RunaId
    where R.RunaId  = prunaid
    group by R.RunaId, R.Name, R.Email, R.Alias, R.Description, R.ProfileImageUrl;

    select A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Ayllu A join AylluRuna AR on A.AylluId = AR.AylluId
         left join Kancha K on AR.RunaId = K.RunaId
    where AR.RunaId = prunaid
    group by A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl;


    select H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Huaca H join Kancha K on H.HuacaId = K.HuacaId
    where K.RunaId = prunaid
    group by H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl;

    select T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna, K.HuacaId
    from Kancha K  join Tambo T on T.TamboId = K.TamboId
    where K.RunaId = prunaid
    group by T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl, K.HuacaId;

    select K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, sum(K.score) as score,
        count(K.NameId) as runakuna_count, K.HuacaId, K.TamboId
    from Kancha K join QuipuName QN on K.NameId = QN.Nameid
         join Quipu Q on K.QuipuId = Q.QuipuId
    where K.RunaId = prunaid
    group by K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, K.HuacaId, K.TamboId;
    COMMIT;
end;
$$

create procedure usp_runa_byid( IN prunaid int)
begin
    select RunaId, Name, Email, Alias, Description, ProfileImageUrl from Runa where RunaId  = prunaid;
end;
$$

create procedure usp_runa_byname( IN pname varchar(128))
begin
    select RunaId, Name, Email, Alias, Description, ProfileImageUrl
    from Runa
    where name  = pname;
end;
$$
create procedure usp_runa_list()
begin
    select RunaId, Name, Email, Alias, Description, ProfileImageUrl from Runa;
end;
$$


create procedure usp_runa_list_kancha()
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
    select R.RunaId, R.Name, R.Email,
           R.Alias, R.Description, R.ProfileImageUrl,
           sum( if (B.score >= 0, B.score, 0) ) as gain,
           sum( if (B.score < 0, B.score, 0) ) as loss,
           count(B.NameId) as rumikuna
    from Runa R join Kancha B on R.RunaId = B.RunaId
    group by R.RunaId, R.Name, R.Email, R.Alias, R.Description, R.ProfileImageUrl
    order by R.Name;
    COMMIT;
end;
$$


/*=========================AYLLU ===================================*/

create procedure usp_ayllu_create(
    IN name varchar(128),
    IN pprofileimageurl varchar(2000))
begin
    INSERT INTO Ayllu (Name, ProfileImageUrl) values(name, pprofileimageurl);
    SELECT LAST_INSERT_ID();
end;
$$
create procedure usp_ayllu_update(
    IN paylluid int,
    IN pname varchar(128),
    IN pemail varchar(256),
    IN palias VARCHAR (2048),
    IN pdescription varchar(2048),
    IN pprofileimageurl varchar(2000)
    )
begin
    update Ayllu
    set Name = pname, Email = pemail, Description = pdescription,
        ProfileImageUrl = pprofileimageurl, alias = palias
    where AylluId = paylluid;
end;

$$

create procedure usp_ayllu_assign_runa(IN aylluid int, IN runaid int )
begin
    insert into AylluRuna (AylluId, RunaId) values (aylluId, runaId);
end;
$$
create procedure usp_ayllu_delete(IN runaid int)
begin
    delete from Ayllu where AylluId = aylluid;
end;

$$

create procedure usp_ayllu_byid( IN paylluid int)
begin
    select AylluId, Name, Email, Alias, Description, ProfileImageUrl  from Ayllu where AylluId  = paylluid;
end;
$$

create procedure usp_ayllu_detail_view_byid( IN paylluid int)
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    select A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Ayllu A join AylluRuna AR on A.AylluId = AR.AylluId left join Kancha K on K.RunaId = AR.RunaId
    where A.AylluId  = paylluid
    group by A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl;

    select R.RunaId, R.Name, R.Email, R.Alias, R.Description, R.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Ayllu A join AylluRuna AR on A.AylluId = AR.AylluId
         join Runa R on AR.RunaId = R.RunaId
         left join Kancha K on K.RunaId = R.RunaId
    where A.AylluId = paylluid
    group by R.RunaId, R.Name, R.Email, R.Alias, R.Description, R.ProfileImageUrl;


    select H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Ayllu A join HuacaAyllu HA on A.AylluId = HA.AylluId
         join Huaca H on HA.HuacaId = H.HuacaId
         left join Kancha K on K.HuacaId = HA.HuacaId
    where A.AylluId = paylluid
    group by H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl;

    select T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna, K.HuacaId
    from Ayllu A join HuacaAyllu HA on A.AylluId = HA.AylluId
         join Kancha K on K.HuacaId = HA.HuacaId
         join Tambo T on T.TamboId = K.TamboId
    where A.AylluId = paylluid
    group by T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl, K.HuacaId;

    select K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, sum(K.score) as score,
        count(K.NameId) as runakuna_count, K.HuacaId, K.TamboId
    from Ayllu A join HuacaAyllu HA on A.AylluId = HA.AylluId
         join Kancha K on K.HuacaId = HA.HuacaId
         join QuipuName QN on K.NameId = QN.Nameid
         join Quipu Q on K.QuipuId = Q.QuipuId
    where A.AylluId = paylluid
    group by K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, K.HuacaId, K.TamboId;
    COMMIT;

end;
$$

create procedure usp_ayllu_byname( IN pname varchar(128))
begin
    select AylluId, Name, Email, Alias, Description, ProfileImageUrl
    from Ayllu where name  = pname;
end;
$$
create procedure usp_ayllu_list()
begin
    select AylluId, Name, Email, Alias, Description, ProfileImageUrl from Ayllu;
end;
$$
create procedure usp_ayllu_list_kancha()
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
    select A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl,
        sum( if (B.score >= 0, B.score, 0) ) as gain,
        sum( if (B.score < 0, B.score, 0) ) as loss,
        count(B.NameId) as rumikuna
    from ayllu A join AylluRuna AR on A.aylluid = AR.aylluid
         join runa R  on AR.runaid = R.runaid
         left join Kancha B on R.runaid = B.runaid
    group by A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl
    order by A.Name;
    COMMIT ;
end;
$$

/*=========================Huaca ===================================*/
create procedure usp_huaca_create(
    IN name varchar(128),
    IN pprofileimageurl varchar(2000))
begin
    INSERT INTO Huaca (Name, ProfileImageUrl) values(name, pprofileimageurl);
    SELECT LAST_INSERT_ID();
end;
$$
create procedure usp_huaca_update(
    IN phuacaid int,
    IN pname varchar(128),
    IN palias VARCHAR (2048),
    IN pdescription varchar(2048),
    IN pprofileimageurl varchar(2000)
    )
begin
    update Huaca
    set Name = pname, Description = pdescription,
        ProfileImageUrl = pprofileimageurl, alias = palias
    where HuacaId = phuacaid;
end;

$$

create procedure usp_huaca_delete(IN huacaid int)
begin
    delete from Huaca where HuacaId = huacaid;
end;
$$

create procedure usp_huaca_assign_ayllu(IN huacaid int, IN aylluid int)
begin
    insert into HuacaAyllu (huacaid, aylluid) values (huacaid, aylluid);
end;
$$

create procedure usp_huaca_byid( IN phuacaid int)
begin
    select HuacaId, Name, Alias, Description, ProfileImageUrl  from Huaca where HuacaId  = phuacaid;
end;
$$
create procedure usp_huaca_detail_byid( IN phuacaid int)
begin
    select HuacaId, Name, Alias, Description, ProfileImageUrl
    from Huaca
    where HuacaId  = phuacaid;

    select A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl
    from Ayllu A join HuacaAyllu HA on A.AylluId = HA.AylluId
    where HA.HuacaId  = phuacaid;

    select R.RunaId, R.Name, R.Email, R.Alias, R.Description, R.ProfileImageUrl, A.AylluId
    from Ayllu A join HuacaAyllu HA on A.AylluId = HA.AylluId
         join AylluRuna AR on A.AylluId = AR.AylluId
         join Runa R on AR.RunaId = R.RunaId
    where HA.HuacaId  = phuacaid;
end;
$$

create procedure usp_huaca_detail_view_byid( IN phuacaid int)
begin

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    select H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Huaca H left join Kancha K on H.HuacaId = K.HuacaId
    where H.HuacaId  = phuacaid
    group by H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl;

    select A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from  Huaca H join HuacaAyllu HA on H.HuacaId = HA.HuacaId
          join Ayllu A on HA.AylluId = A.AylluId
          left join AylluRuna AR on A.AylluId = AR.AylluId
          left join Kancha K on K.RunaId = AR.RunaId
    where H.HuacaId = phuacaid
    group by A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl;

    select T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl,
        sum( if (K.score >= 0, K.score, 0) ) as gain,
        sum( if (K.score < 0, K.score, 0) ) as loss,
        count(K.NameId) as rumikuna
    from Tambo T left join Kancha K on K.TamboId = T.TamboId
    where K.HuacaId = phuacaid
    group by T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl;

    select K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, sum(K.score) as score,
        count(K.NameId) as runakuna_count, K.HuacaId, K.TamboId
    from Huaca H
         join Kancha K on K.HuacaId = H.HuacaId
         join QuipuName QN on K.NameId = QN.Nameid
         join Quipu Q on K.QuipuId = Q.QuipuId
    where H.HuacaId = phuacaid
    group by K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, K.HuacaId, K.TamboId;

    COMMIT;
end;
$$

create procedure usp_huaca_byname( IN pname varchar(128))
begin
    select HuacaId, Name, Alias, Description, ProfileImageUrl  from Huaca where Name  = pname;
end;
$$

create procedure usp_huaca_list()
begin
    select HuacaId, Name, Alias, Description, ProfileImageUrl from Huaca;
end;
$$
create procedure usp_huaca_list_kancha()
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    select W.HuacaId, W.Name, W.Alias, W.Description, W.ProfileImageUrl,
            sum( if (B.score >= 0, B.score, 0) ) as gain,
            sum( if (B.score < 0, B.score, 0) ) as loss,
            count(B.NameId) as rumikuna
    from Huaca W join Kancha B on W.HuacaId = B.HuacaId
    group by HuacaId, Name, Alias, Description, ProfileImageUrl
    order by W.Name;
    COMMIT;
end;
$$


/*=========================TAMBO ===================================*/
create procedure usp_tambo_create(
    IN name varchar(128))
begin
    INSERT INTO Tambo (Name) values(name);
    SELECT LAST_INSERT_ID();
end;
$$
create procedure usp_tambo_update(
    IN ptamboid int,
    IN pname varchar(128),
    IN pdynfunction VARCHAR (4000),
    IN pdescription varchar(2048),
    IN pprofileimageurl varchar(2000)
    )
begin
    update Tambo
    set Name = pname, Description = pdescription,
        ProfileImageUrl = pprofileimageurl, DynFunction= pdynfunction
    where TamboId = ptamboid;
end;

$$

create procedure usp_tambo_delete(IN ptamboid int)
begin
    delete from Tambo where TamboId = ptamboid;
end;

$$

create procedure usp_tambo_byid( IN ptamboid int)
begin
    select TamboId, Name, DynFunction, Description, ProfileImageUrl  from Tambo where TamboId  = ptamboid;
end;
$$
create procedure usp_tambo_detail_view_byid( IN ptamboid int)
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    select T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl,
            sum( if (K.score >= 0, K.score, 0) ) as gain,
            sum( if (K.score < 0, K.score, 0) ) as loss,
            count(K.NameId) as rumikuna
    from Tambo T left join Kancha K on T.TamboId = K.TamboId
    where T.TamboId  = ptamboid
    group by T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl;

    select A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl,
            sum( if (K.score >= 0, K.score, 0) ) as gain,
            sum( if (K.score < 0, K.score, 0) ) as loss,
            count(K.NameId) as rumikuna
    from Ayllu A join AylluRuna AR on A.AylluId = AR.AylluId
          join Kancha K on AR.RunaId = K.RunaId
    where K.TamboId  = ptamboid
    group by A.AylluId, A.Name, A.Email, A.Alias, A.Description, A.ProfileImageUrl;

    select H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl,
            sum( if (K.score >= 0, K.score, 0) ) as gain,
            sum( if (K.score < 0, K.score, 0) ) as loss,
            count(K.NameId) as rumikuna
    from  Huaca H
          join Kancha K on K.HuacaId = K.HuacaId
    where K.TamboId  = ptamboid
    group by H.HuacaId, H.Name, H.Alias, H.Description, H.ProfileImageUrl;

    select K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, sum(K.score) as score,
        count(K.NameId) as runakuna_count, K.HuacaId, K.TamboId
    from Kancha K
         join QuipuName QN on K.NameId = QN.Nameid
         join Quipu Q on K.QuipuId = Q.QuipuId
    where K.TamboId = ptamboid
    group by K.QuipuId, QN.Nameid, QN.Name, Q.CreatedOn, K.HuacaId, K.TamboId;


    COMMIT;
end;
$$



create procedure usp_tambo_byname( IN pname varchar(128))
begin
    select TamboId, Name, DynFunction, Description, ProfileImageUrl  from Tambo where Name = pname;
end;
$$
create procedure usp_tambo_by_aylluid_view(IN paylluid int)
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        select T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl,
            sum( if (score >= 0, score, 0) ) as gain,
            sum( if (score < 0, score, 0) ) as loss,
            count(nameid) as rumikuna
        from Tambo T left join Kancha K on T.tamboid = K.tamboid
             join AylluRuna AR on AR.RunaId = K.RunaId
        where AR.AylluId = paylluid
        group by T.TamboId, T.Name, T.DynFunction, T.Description, T.ProfileImageUrl;
    COMMIT;
end;
$$

create procedure usp_tambo_list()
begin
    select TamboId, Name, DynFunction, Description, ProfileImageUrl from Tambo;
end;
$$

create procedure usp_system_clean_data()
begin
    delete from Kancha;
    delete from Quri;
    delete from QuipuName;
    delete from QuipuIssue;
    delete from Quipu;
    delete from Tambo;
    delete from Huaca;
    delete from Ayllu;
    delete from Runa;
    delete from User;
end;
$$
create procedure usp_ayni_stats()
begin
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
		select max(quipuid) as lastquipu from quipu;
        select max(quipuid) as lastprocessquipu from quri;
        select count(runaid) as runakuna from runa;
        select count(huacaid) as huacakuna from huaca;
        select count(aylluid) as ayllukuna from ayllu;
        select count(tamboid) as tambokuna from tambo;

        select
            sum( if (score >= 0, score, 0) ) as gain,
            sum( if (score < 0, score, 0) ) as loss,
            count(nameid) as rumikuna
        from kancha
        group by nameid;

		select
			sum( if (B.score >= 0, B.score, 0) ) as gain,
			sum( if (B.score < 0, B.score, 0) ) as loss,
			count(R.runaid) as runakuna
		from runa R join kancha B on R.runaid = B.runaid
        group by R.runaid;

        select
			sum( if (B.score >= 0, B.score, 0) ) as gain,
			sum( if (B.score < 0, B.score, 0) ) as loss,
			count(R.huacaid) as huacakuna
		from huaca R join kancha B on R.huacaid = B.huacaid
        group by R.huacaid;

        select
			sum( if (B.score >= 0, B.score, 0) ) as gain,
			sum( if (B.score < 0, B.score, 0) ) as loss,
			count(A.aylluid) as ayllukuna
		from ayllu A join aylluruna AR on A.aylluid = AR.aylluid
				     join kancha B on AR.runaid = B.runaid
        group by A.aylluid;

        select
			sum( if (B.score >= 0, B.score, 0) ) as gain,
			sum( if (B.score < 0, B.score, 0) ) as loss,
			count(R.tamboid) as tambokuna
		from tambo R join kancha B on R.tamboid = B.tamboid
        group by R.tamboid;

    COMMIT;
end;
$$


