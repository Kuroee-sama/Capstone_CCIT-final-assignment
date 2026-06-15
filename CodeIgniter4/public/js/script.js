document.addEventListener('DOMContentLoaded', () => {
    // POS System Logic
    const menuGrid = document.querySelector('.menu-grid');
    const cartItemsContainer = document.querySelector('.cart-items');
    const cartTotalElement = document.getElementById('cart-total');
    const checkoutBtn = document.getElementById('checkout-btn');
    const pelangganSelect = document.getElementById('pelanggan-select');
    
    let cart = [];

    if (menuGrid) {
        // Add item to cart
        menuGrid.addEventListener('click', (e) => {
            const card = e.target.closest('.menu-item');
            if (!card) return;

            const id = card.dataset.id;
            const name = card.dataset.name;
            const price = parseInt(card.dataset.price);

            addToCart(id, name, price);
        });

        // Checkout process
        if (checkoutBtn) {
            checkoutBtn.addEventListener('click', async () => {
                if (cart.length === 0) {
                    alert('Cart is empty!');
                    return;
                }

                const pelangganId = pelangganSelect ? pelangganSelect.value : 1; // Default or selected
                
                const payload = {
                    id_pelanggan: pelangganId,
                    id_karyawan: 1, // Should come from session/auth context
                    items: cart.map(item => ({
                        id_barang: item.id,
                        jumlah: item.qty
                    }))
                };

                try {
                    const response = await fetch('/api/transaksi', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: JSON.stringify(payload)
                    });

                    const result = await response.json();

                    if (response.ok) {
                        alert('Transaction successful!');
                        cart = [];
                        renderCart();
                        window.location.href = `/transaksi/detail/${result.id}`;
                    } else {
                        alert('Transaction failed: ' + (result.messages ? JSON.stringify(result.messages) : result.message));
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('An error occurred during checkout.');
                }
            });
        }
    }

    function addToCart(id, name, price) {
        const existingItem = cart.find(item => item.id === id);

        if (existingItem) {
            existingItem.qty++;
        } else {
            cart.push({ id, name, price, qty: 1 });
        }

        renderCart();
    }

    function removeFromCart(id) {
        cart = cart.filter(item => item.id !== id);
        renderCart();
    }

    function updateQty(id, change) {
        const item = cart.find(item => item.id === id);
        if (item) {
            item.qty += change;
            if (item.qty <= 0) {
                removeFromCart(id);
            } else {
                renderCart();
            }
        }
    }

    function renderCart() {
        if (!cartItemsContainer) return;

        cartItemsContainer.innerHTML = '';
        let total = 0;

        cart.forEach(item => {
            const itemTotal = item.price * item.qty;
            total += itemTotal;

            const div = document.createElement('div');
            div.className = 'cart-item';
            div.innerHTML = `
                <div>
                    <div style="font-weight: 500;">${item.name}</div>
                    <div style="font-size: 0.85rem; color: #64748b;">Rp ${item.price.toLocaleString()} x ${item.qty}</div>
                </div>
                <div style="text-align: right;">
                    <div style="font-weight: 600;">Rp ${itemTotal.toLocaleString()}</div>
                    <div style="margin-top: 5px;">
                        <button class="btn-xs btn-outline" onclick="updateCartQty('${item.id}', -1)">-</button>
                        <button class="btn-xs btn-outline" onclick="updateCartQty('${item.id}', 1)">+</button>
                    </div>
                </div>
            `;
            cartItemsContainer.appendChild(div);
        });

        if (cartTotalElement) {
            cartTotalElement.textContent = 'Rp ' + total.toLocaleString();
        }
    }

    // Expose helpers globally for inline onclicks
    window.updateCartQty = (id, change) => updateQty(id, change);
});
