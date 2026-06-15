<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

/**
 * RoleFilter — ensures the logged-in user has the required role.
 * Usage in Routes.php: 'filter' => 'role:admin' or 'role:admin,karyawan'
 */
class RoleFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        // Must be logged in first
        if (!session()->get('isLoggedIn')) {
            return redirect()->to('/login')->with('error', 'Silakan login terlebih dahulu.');
        }

        // If no specific roles required, just check login
        if (empty($arguments)) {
            return;
        }

        $userRole = strtolower(session()->get('role') ?? '');

        // Check if user's role is in the allowed roles
        if (!in_array($userRole, $arguments)) {
            return redirect()->to('/admin/dashboard')->with('error', 'Anda tidak memiliki akses ke halaman tersebut.');
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // No action after request
    }
}
