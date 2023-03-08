use master

if exists (select * from sys.databases where Name='Session12') 
drop database Session12
go

create database Session12
go

use Session12


--CREATE TABLE

create table Brand ( 
  b_id int identity (1,1) primary key,
  b_name varchar(40) not null,
  b_address varchar(50) not null,
  b_phone  varchar(15) not null,
)

create table Product (
 p_id int identity(1,1) primary key,
 p_name nvarchar(40) not null,
 p_desc nvarchar(50) not null,
 p_price money not null,
 current_quantity int not null,
 b_id int not null,
 foreign key (b_id) references Brand(b_id) 
)

alter table Product 
  add p_unit nvarchar(20) not null
go

set identity_insert Brand on;
insert into Brand(b_id, b_name, b_address, b_phone) values (123, 'Asus', 'USA', '983232')
insert into Brand(b_id, b_name, b_address, b_phone) values (124, 'Dell', 'USA', '123244')
insert into Brand(b_id, b_name, b_address, b_phone) values (125, 'HP', 'China', '435467')

select * from Brand

insert into Product(p_name, p_desc, p_price, current_quantity, b_id, p_unit) 
   values (N'Máy tính T450', N'Máy nhập cũ', 1000, 10, 123, N'Chiếc')

insert into Product(p_name, p_desc, p_price, current_quantity, b_id, p_unit)
    values (N'Điện thoại Nokia5670', N'Điện thoại đang hot', 200, 200, 123, N'Chiếc')

insert into Product (p_name, p_desc, p_price, current_quantity, b_id, p_unit)
    values (N'Máy in Samsung450', N'Máy in đang loại bình', 100, 10, 123, N'Chiếc')

insert into Product (p_name, p_desc, p_price, current_quantity, b_id, p_unit)
    values (N'Máy in Samsung450', N'Máy in đang loại bình', 100, 10, 124, N'Chiếc')


insert into Product (p_name, p_desc, p_price, current_quantity, b_id, p_unit)
    values (N'Máy in Samsung550', N'Máy in đang loại bình', 100, 0, 123, N'Chiếc')

insert into Product (p_name, p_desc, p_price, current_quantity, b_id, p_unit)
    values (N'Máy in Samsung650', N'Máy in đang loại bình', 100, 0, 124, N'Chiếc')

insert into Product (p_name, p_desc, p_price, current_quantity, b_id, p_unit)
    values (N'Máy in Samsung750', N'Máy in đang loại bình', 100, 0, 125, N'Chiếc')

select * from Product

--4: -hiển thị tất cả các hãng sản xuất
     select * from Brand order by b_name

    -- hiển thị tất cả các sản phẩm
	select * from Product order by current_quantity desc

--5:  --danh sách hãng theo thứ tự ngược của tên
    select * from Brand order by b_name desc
    
	  --danh sách sp theo giá giảm dần
	  select * from Product order by p_price desc

	  --hiển thị thông tin brand Asus
	  select * from Brand where b_name like 'Asus'

	  --hiển thị ds sản phẩm còn ít hơn 11 chiếc trong kho
	  select * from Product where current_quantity < 11

	  --ds sản phẩm hãng Asus

	  select p.*
	  from 
	     Product as p
		 inner join Brand as b on p.b_id = b.b_id and b.b_name like 'Asus'
      
	  go
--6:  -- số hãng 
      select count(*) as Number_of_Brand
	   
      from Brand
	  go

      -- số sản phẩm
	  select count(*) as Number_of_Product
	  from Product
	  go

	  -- tổng số các loại sản phẩm mỗi hãng có trong của hàng
	  select p.p_id, p.p_name,
	        count(*) Number_of_Product_on_Brand
	  from Product as p inner join Brand as b on p.b_id = b.b_id
	  group by p.p_id, p.p_name
	  go

	  -- tổng số đầu sản phẩm của toàn của hàng 

	  select p.p_id, sum (p.current_quantity) as 'SumQuantity'
	  from Product as p
	  group by p.p_id
	  go

--7:  --thay đổi trường giá tiền của từng mặt hàng > 0
      alter table Product 
	    add constraint CheckPrice check (p_price > 0 )
      go


      -- thay đổi số điện thoại bắt đầu  = 0
	  
	  select ('0' + b.b_phone ) as 'PhoneNumber'
	  from Brand as b 

	 

	  update 
	     Brand 
      set 
	     b_phone = '0' + b_phone
	   
	  where 
	    charindex ('0', b_phone, 1) not in (1)
	  go   
	    
      select * from Brand


--8: --index cho cột: tên hàng và mô tả hàng để tăng hiệu suất truy vấn dữ lieuj

   create index IX_Product_Name 
   on Product (p_name)
   go

   create index IX_Product_Desc
   on Product (p_desc)
   go

     -- view: 
	     	 --View sản phẩm: vói các cột mã sp, tên sản phẩm, giá bán
			 drop view if exists Product_View
			 go

			 create view Product_View 
			 as 
			 select
			   p.p_id,
			   p.p_name,
			   p.p_price
             from Product as p
			 go

			 select * from Product_View
			 go

			 --View sản phẩm_brand với các cột mã sản phẩm , name, brand

			 drop view if exists Product_Brand_View
			 go

			 create view Product_Brand_View
			 as 
			 select 
			    p.p_id as Product_Id,
				p.p_name as Product_Name,
				b.b_name as Brand_Name
			 from 
			    Product as p
				inner join Brand as b  on p.b_id = b.b_id
             go

			 select * from Product_Brand_View
			 go

	--Store procedure: thủ tục lưu trữ
	        -- liệt kê các sản phẩm vói tên hãng truyền vào store
			drop procedure if exists SelectProductsByBrandName 
			go

			create procedure SelectProductsByBrandName @B_Name varchar(40)
			as 
			 select 
			     p.*
             from 
			    Product as p inner join Brand as b on p.b_id = b.b_id  and b.b_name = @B_Name
            go 

			exec SelectProductsByBrandName @B_Name='Dell' 

			--liệt kê các sản phẩm có giá bán lớn hơn hoặc bằng giá bán truyền vào

			drop procedure if exists SelectProductsByPrice 
			go

			create procedure SelectProductsByPrice @P_Price money 
			as 
			select
			   p.*
            from 
			  Product as p 
            where p.p_price >= @P_Price
			go

			exec SelectProductsByPrice @P_Price = 80.00


			--liệt kê các sản phẩm đã hết hàng (số lượng = 0)

			drop procedure if exists SelectProductsSoldOut
			go
			
			create procedure SelectProductsSoldOut 
			
			as
			select 
			   p.*
            from Product as  p
			where p.current_quantity = 0
			go
			
			exec SelectProductsSoldOut
			go


     
	 --trigger: 

	        --ngăn không cho xóa brand -- Trigger DDL

			create trigger trDatabase_OnDropTable
			on database
			for drop_table
			as 
			begin
			   set nocount on ;

			   --get table on Schema and table name from Evendata()
			   declare @Schema sysname = eventdata().value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
			   declare @Table sysname = eventdata().value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname');

			   if @Schema = 'dbo' and @Table = 'Brand'
			   begin
			      print 'Drop Table Issued.';

				  raiserror ('[dbo].[Brand] cannot be dropped.', 16, 1);
				  rollback;

			   end

			   else 
			   begin
			      --do nothing, allow table to be dropped
				  print 'Table dropped: [' + @Schema + '].[' + @Table + ']';

			   end


			end;

			--try drop table Brand
			
			  -- xoa rang buoc khoa ngoai truoc
			alter table Product
			  drop  constraint [FK__Product__b_id__4BAC3F29]

			
			drop table Brand 

			--tao lai rang buoc FK

			alter table Product
			  add constraint FK_BrandID foreign key (b_id) references Brand(b_id)
            

			


			--chỉ cho phép xóa các sản phẩm đã hết hàng

			