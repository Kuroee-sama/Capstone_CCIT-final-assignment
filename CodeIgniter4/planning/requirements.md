# API for Transactions in Cafes

Silakan tempel (paste) bagian TEXT dari dokumen Word di sini. 
Termasuk:
- Endpoint routes
- Response examples
- Logic rules
Authentication Controller
No	HTTP Method	Endpoint	Description
1	POST	/api/auth/register	Register a new karyawan account
2	POST	/api/auth/login	Authenticate karyawan and generate JWT token
3	GET	/api/auth/health	Check authentication service status

Karyawan Controller
No	HTTP Method	Endpoint	Description
1	GET	/api/karyawan	Retrieve all karyawan lists
2	GET	/api/karyawan/{id}	Retrieve karyawan details by ID
3	POST	/api/karyawan	Create a new karyawan entry
4	POST	/api/karyawan/bulk	Create multiple karyawan at once
5	PUT	/api/karyawan/{id}	Update karyawan information
6	DELETE	/api/karyawan/{id}	Delete karyawan by ID
7	DELETE	/api/karyawan/bulk	Delete multiple karyawan by ID

Menu Controller
No	HTTP Method	Endpoint	Description
1	GET	/api/menu	Retrieve all menu items
2	GET	/api/menu/{id}	Retrieve menu details by ID
3	GET	/api/menu/kategori/{kategori}	Retrieve menus based on categories (food/drinks)
4	POST	/api/menu	Add a new menu item
5	POST	/api/menu/bulk	Add multiple menus at once (Bulk Create)
6	PUT	/api/menu/{id}	Update menu details
7	DELETE	/api/menu/{id}	Remove a menu item
8	DELETE	/api/menu/bulk	Deleting multiple menus at once
9	PATCH	/api/menu/{id}/stok	Update only stock of menu item

Transaksi Controller
No	HTTP Method	Endpoint	Description
1	POST	/api/transaksi	Create a new Transactions
2	GET	/api/transaksi	Retrieve Transactions history
3	GET	/api/transaksi/{id}	Get Transactions details by ID
