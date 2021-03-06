	S E T   A N S I _ N U L L S   O N 
 G O 
 S E T   Q U O T E D _ I D E N T I F I E R   O N 
 G O 

 / * 
 	 C R E A T E D   B Y :   	 	 E m i l e   F r a s e r 
 	 D A T E :   	 	 	 	 	 2 0 2 0 - 1 2 - 1 0 
 	 D E C S R I P T I O N :   	 D y n a m i c   P r o c e d u r e   T e n p l a t e 
 	 T O D O : 
 * / 
 C R E A T E   O R   A L T E R   P R O C E D U R E   [ s c h e m a ] . [ p r o c n a m e ] 
 A S   
 B E G I N 

-- Only allowable statement before Begin Try 
 S E T   X A C T _ A B O R T ,   N O C O U N T   O N 
 
BEGIN TRY
BEGIN TRANSACTION

 
 	 - -   V a r i a b l e s   f o r   P r o c   C o n t r o l 
     D E C L A R E 
     , 	 @ s q l _ d e b u g   	 	 	 B I T   	 	 =   1 
     ,         @ s q l _ e x e c u t e   	 	   B I T   	         =   0 
     , 	 @ s q l _ l o g     	 	 	 	  TINYINT	 	   =   0     -- )0 =  no, 1 = yes, 2 = yes without drop
   
 - -   D y n a m i c   P r o c e d u r e   V a r i a b l e s 
 D E C L A R E   
     	   @ s q l _ s t a t e m e n t   	 N V A R C H A R ( M A X ) 
     , 	 @ s q l _ p a r a m aet e r   	 N V A R C H A R ( M A X ) 
     , 	 @ s q l _ m e s s a g e   	       N V A R C H A R ( M A X ) 
     ,         @ s q l _ t a b 	 	 	 	       N V A R C H A R ( 1 )         	 	 =   C H A R ( 9 ) 
     , 	 @ s q l _ c r l f   	 	 	             N V A R C H A R ( 2 )   	 	     =   C H A R ( 1 3 )   +   C H A R ( 1 0 ) 
     , 	 @ c u r s o r _ e x e c   	 	 C U R S O R  LOCAL FAST_FORWARD 
 
     - -   O p t i o n a l   R o w C o u n t   V a r i a b l e 
     D E C L A R E 
     	 @ s q l _ rowcount  I N T 
     ,   @ s q l _ r e t u r n code  I N T 
    
-- Time Parameters
DECLARE 
	@sql_starttime DATETIME2(7)
	, @sql_endtime DATETIME2(7)
	, @sql_runtime_sec INT

     - -   O p t i o n a l   s t r i n g   f i l t e r s 
 D E C L A R E   
 	 @ f i l t e r _ i n c l u d e 	 	 N V A R C H A R ( M A X ) 
 	 , @ e q u a l i t y _ i n c l u d e   N V A R C H A R ( M A X ) 
   ,   @ f i l t e r _ e x c l u d e   	 N V A R C H A R ( M A X ) 
     , @ e q u a l i t y _ e x c l u d e       N V A R C H A R ( M A X ) 

 - -   S q l   V a r i a b l e s   u s e d   f o r   o b j e c t   i d e n t i f i c a t i o n 
 D E C L A R E 
 	 @ s e r v e r n a m e 	 	 	 	 S Y S N A M E 
 	 , @ d a t a b a s e n a m e 	 	     S Y S N A M E 
 	 , @ s c h e m a n a m e                           S Y S N A M E 
 	 , @ o b j e c t n a m e 	 	 	 	 S Y S N A M E 
 	 , @ o b j e c t t y p e 	 	 	 	     S Y S N A M E 
 	 , @ i n d e x n a m e 	 	 	 	     S Y S N A M E 
 	 , @ i n d e x t y p e 	 	 	 	 	 S Y S N A M E 

-- Log Variables
DECLARE
	@log_stepname NVARCHAR(MAX)
	,@log_stepdefinition NVARCHAR(MAX)
	,@log_stepparameter_out NVARCHAR(MAX)

IF (@sql_log =! 0)
BEGIN
 	 - -   Temp L o g g i n g   t a b l e 
DROP TABLE IF EXISTS ##log
 	 CREATE  T A B L E    ##log ( 
 	 	   L o g I D 	 	 	 	 	 I N T   I D E N T I T Y ( 1 , 1 ) 
 	 , 	 S t e p N a m e 	 	 	 N V A R C H A R ( 1 0 0 ) 
 	 , 	 S t e p D e f i n i t i o n 	 N V A R C H A R ( M A X ) 
 	 , 	 S t e p Parameter_Out              	   N V A R C H A R ( M A X ) 
	 , 	 S t e p R eturnCode	 	       Int
	,    StepStartDT   DATETIME2(7)
	    , StepEndDT  DATETIME2(7)
	     , StepRunTime IN
 	 ,         StepE r r o r M e s s a g e         N V A R C H A R ( M A X ) 
 	 ) 
 END

  - -   C u r s o r   d e c l a r a t i o n 
  S E T   @ c u r s o r _ e x e c   =   C U R S O R   F O R   
 S E L E C T   
 	  s c h . n a m e 
 , 	o b j . n a m e 
  FR O M   
     	 s y s . o b j e c t s   A S   o b j    
 I N N E R   J O I N   
 	s y s . s c h e m a s A S   s c h 
	O N   s c h . s c h e m a _ i d   =   o b j . s c h e m a _ i d   
  W H E R E   
 	 o b j . n a m e   =   @ f i l t e r _ i n c l u d e
A N D 
	o b j . n a m e   ! =   @ f i l t e r _ e x c l u d e 
 
-- Opening Cursor
 O P E N   @ c u r s o r _ e x e c 
 
-- Initial Fetch from Cursor 
  F E T C H   N E X T   F R O M   @ c u r s o r _ e x e c 
 IN T O   @ s c h e m a n a m e ,   @ objectname
 
-- Cursor Loop
 W H I L E ( @ @ F E T C H _ S T A T U S   =   0 ) 
 B E G I N 
        -- Initializes start time
        SET @sql_starttime = GETDATE()
   
        -- Dynamic statement generation
 	 	 S E T   @ s q l _ s t a t e m e n t   =   ' S E L E C T   @ sql_rowcount =  COUNT(1) FROM  ' + QUOTENAME(@schemaname) + '.' + QUOTENAME(@objectname)  + ';' + @sql_crlf
 	 	 S E T   @ s q l _ p a r a m a t e r   =   ' @ sql_rowcount  I N T   O U T P U T ' 
 
				-- Debug Part
 	 	 	 	 I F   ( @ s q l _ d e b u g   =   1 ) 
 	 	 	 	 B E G I N 
 	 	 	 	       S E T   @ s q l _ m e s s a g e   =   @ s q l _ s t a t e m e n t   +   @sql_crlf + ' {{'   +   @sql_parameter + '}}'
 	 	 	 	 	 R A I S E R R O R ( @ s q l _ m e s s a g e ,   0 ,   1 )   W I T H   N O W A I T 
 	 	 	 	 E N D 
 
				-- Execute Part
 	 	 	 	 I F   ( @ s q l _ e x e c u t e   =   1 ) 
 	 	 	 	 B E G I N 
 	 	 	 	 B E G I N   T R Y 
 	 	 	 	 E X E C  @sql_return =  s p _ e x e c u t e s q l   
 	 	 	 	 	 	 	 @ s t m t 	 	 	 =   @ s q l _ s t a t e m e n t 
 	 	 	 	  	  , 	 @ p a r a m 	 	 	 =   @ s q l _ p a r a m a t e r 
 	 	 	        	 , 	 @ sql_rowcount	 	 =   @ sql_rowcount O U T P U T 
 	 	 	 	 
				-- Log Part
 	 	 	 	 I F   ( @ s q l _ log  =   1 ) 
 	 	 	 	 B E G I N 
  		   	    
						-- Log variables init
                     SET @log_stepname = concat_ws('|',@schemaname ,@objectname)
			       		set @log_stepdefinition =   @ s q l _ s t a t e m e n t   + ' {{'   +   @sql_parameter + '}}'
						 set @log_parameter_out  = @sql_rowcount

						 -- Deinitializes time
        	   	      SET @sql_endtime = GETDATE()
						 SET @sql_runtime = DATEDIFF(SECONDS, @sql_starttime, @sql_endtime)
						 
						 
						-- Logs success into @log
 	 	 	 	         I N S E R T   I N T O  ##l o g   ( S t e p N a m e ,   S t e p D e f i n i t i o n ,   StepParameter_Out, S t e p R e turnCode,   StepStartDT, StepEndDT, StepRunTime, S t e p ErrorM e s s a g e ) 
 	 	 	 	 	 	 S E L E C T   @ log_stepname, @log_stepdefinition,  @log_stepparameter_out,  @ s q l _ returncode,   @sql_starttime, @sql_endtime, @sql_runtime, N U L L 
 	 	 	 	 E n d 
 	 	 	 	 
 	 	 	 	 	 E N D   T R Y 
 	 	 	 	 	 B E G I N   C A T C H 
 	 	 	 	 	 I F   ( @ s q l _ log  =   1 ) 
 	 	 	 	 B E G I N 
	   			 	-- Logs failure
	   			 	
	   			 	-- Log variables init
                     SET @log_stepname = concat_ws('|',@schemaname ,@objectname)
			       		set @log_stepdefinition =   @ s q l _ s t a t e m e n t   + ' {{'   +   @sql_parameter + '}}'
						 set @log_parameter_out  = @sql_rowcount

	   			 	 -- Deinitializes time
        	   	      SET @sql_endtime = GETDATE()
						 SET @sql_runtime = DATEDIFF(SECONDS, @sql_starttime, @sql_endtime)
	   			 	
						 -- Logs failures into @log
						  I N S E R T   I N T O   ##l o g   ( S t e p N a m e ,   S t e p D e f i n i t i o n ,   StepParameter_Out, S t e p R e turnCode,   StepStartDT, StepEndDT, StepRunTime, S t e p ErrorM e s s a g e ) 
 	 	 	 	 	 	 S E L E C T   @ log_stepname, @log_stepdefinition,  @log_stepparameter_out,  @ s q l _ returncode,   @sql_starttime, @sql_endtime, @sql_runtime, ERROR_MESSAGE() 
 	 	 	 
	   			 	
 	 	 	 	 	 	 	 	 E N D 
 	 	 	 	 	 	 
 	 	 	 	 	 	 E N D   C A T C H 
 	 	 	 	 E N D 
 	 	 	 	 
 
     -- Feches next from cursor
 	 F E T C H   N E X T   F R O M   @ c u r s o r _ e x e c 
 	 I N T O   @ s c h e m a n a m e ,   @ objectn a m e 
 
 E N D 
 
-- Selects value to screen
 S E L E C T   *   F R O M   ##l o g 
 
-- Drops log temp table if not set to keep
IF (@sql_log = 1)
BEGIN
    DROP TABLE IF EXISTS ##log
END

-- COMMITS FULL CURSOR TRANSACTION
COMMIT TRANSACTION

END TRY


B E G I N   C A T C H 

 	 	 - -   T e s t   X A C T _ S T A T E   f o r   0 ,   1 ,   o r   - 1   ( M u s t   H a v e   e n a b l e d   X A C T _ A B O R T   O N ) 
                 - -   T r a n s a c t i o n   i s   a c t i v e   a n d   v a l i d   t h u s   c o m m i t a b l e 
 	 	 I F   ( X A C T _ S T A T E ( )   >   0   A N D   @ @ T R A N C O U N T   >   0 ) 
                 B E G I N                      
 	 	 	 C O M M I T   T R A N S A C T I O N 
                         R E T U R N   0
                 E N D 

 	         - -   T r a n s a c t i o n   i s   n o t   u n c o m m i t t a b l e   a n d   s h o u l d   b e   r o l l e d   b a c k 	 
 	 	 E L S E   I F   ( X A C T _ S T A T E ( )   <   0   A N D   @ @ t r a n c o u n t   >   0 ) 
                 B E G I N  
                         ; T H R O W  
 	 	 	 R O L L B A C K   T R A N S A C T I O N 
 	 	 E N D 
  
                 - -   T h e r e   i s   n o   t r a n s c t i o n ,   t r y i n g   t o   c o m m i t   w o u l d   g e n e r a t e   e r r o r 
                  E L S E   I F   ( X A C T _ S T A T E ( )   =   0   O R     @ @ T R A N C O U N T   =   0 )   
                 B E G I N 
                          ; T H R O W 
                 E N D 
 
               - -   R u n   f o r   t h e   h i l l s ,   o u r   S Q L   i n s t a n c e   h a s   b e e n   c o r r u p t e d 
                 E L S E    
                 B E G I N  
                         R A I S E R R O R ( ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *   E R R O R   * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ' ,   1 6 ,   1 )  
                         R A I S E R R O R ( ' A   s e r i o u s   e r r o r   h a s   o c c u r e d ,   p l e a s e   c o n t a c t   y o u r   D B A   i m m e d i a t e l y ' ,   1 6 ,   1 )  
                         R A I S E R R O R ( ' T h e s e   c o m m a n d s   n e e d   t o   b e   r u n ,   t o   p r e v e n t   c a t a s t r o p h i c   d a t a   l o s s : ' ,   1 6 ,   1 ) 
                         R A I S E R R O R ( ' U S E   m a s t e r ' ,   1 6 ,   1 ) 
                         R A I S E R R O R ( ' G O ' ,   1 6 ,   1 )  
                         R A I S E R R O R ( ' A L T E R   D A T A B A S E   D B _ N A M E ( )   S E T   S I N G L E _ U S E R   W I T H   R O L L B A C K   I M M E D I A T E ' ,   1 6 ,   1 )  
                         R A I S E R R O R ( ' G O ' ,   1 6 ,   1 ) 
                         R A I S E R R O R ( ' A L T E R   D A T A B A S E   D B _ N A M E ( )   S E T   R E A D _ O N Y ' ,   1 6 ,   1 ) 
                         R A I S E R R O R ( ' G O ' ,   1 6 ,   1 ) 
                 E N D 
 
         E N D   C A T C H 

 E N D