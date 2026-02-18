let pricePerLiter = 4.99;
let isStarted = false;

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.type === "open") {
        document.body.style.display = "block";
        pricePerLiter = data.price;
        isStarted = false;
        
        // FIX: Hier muss 'price-display' stehen (passend zur HTML)
        const priceLabel = document.getElementById('price-display');
        if (priceLabel) {
            priceLabel.innerText = `${pricePerLiter.toFixed(2).replace('.', ',')}$ = 1L`;
        }
        
        updateUI(data.currentFuel, 0);
        document.querySelectorAll('button').forEach(b => b.style.opacity = "1");
    } else if (data.type === "update") {
        updateUI(data.fuel, data.added);
    }
});

function updateUI(fuel, added) {
    const fuelBar = document.getElementById('fuel-progress');
    const fuelText = document.getElementById('fuel-text');
    const litersVal = document.getElementById('liters-val');
    const totalPrice = document.getElementById('total-price');

    if (fuelBar) fuelBar.style.width = fuel + "%";
    if (fuelText) fuelText.innerText = Math.floor(fuel) + "%";
    if (litersVal) litersVal.innerText = added.toFixed(1) + "L";
    if (totalPrice) totalPrice.innerText = Math.ceil(added * pricePerLiter) + "$";
}

function selectMethod(method) {
    if (isStarted) return;
    isStarted = true;
    document.querySelectorAll('.button-group button').forEach(b => b.style.opacity = "0.3");
    fetch(`https://${GetParentResourceName()}/startWithMethod`, {
        method: 'POST',
        body: JSON.stringify({ method: method })
    });
}

function closeUI() {
    document.body.style.display = "none";
    fetch(`https://${GetParentResourceName()}/closeAndPay`, { method: 'POST' });
}