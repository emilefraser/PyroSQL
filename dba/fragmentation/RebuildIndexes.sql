/* Most effective method */

exec sp_MSforeachtable  'SET QUOTED_IDENTIFIER ON; ALTER INDEX ALL ON ? REBUILD'

