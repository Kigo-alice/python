//  JavaScript Fundamentals Assignment

// Part 1: Variables, Data Types, Conditionals
document.getElementById("checkAgeBtn").addEventListener("click", () => {
    let age = document.getElementById("ageInput").value; // variable
    age = Number(age); // convert to number
  
    // conditional logic
    if (age >= 18) {
      document.getElementById("ageResult").textContent = "You are an adult ✅";
    } else if (age > 0) {
      document.getElementById("ageResult").textContent = "You are underage ❌";
    } else {
      document.getElementById("ageResult").textContent = "Please enter a valid age!";
    }
  });
  
  //  Part 2: Functions — Reusability
  function calculateTotal(a, b) {
    return a + b;
  }
  
  function formatResult(result) {
    return `The total is: ${result}`;
  }
  
  document.getElementById("calcBtn").addEventListener("click", () => {
    const n1 = Number(document.getElementById("num1").value);
    const n2 = Number(document.getElementById("num2").value);
  
    const total = calculateTotal(n1, n2); // reusable function
    document.getElementById("calcResult").textContent = formatResult(total);
  });
  
  // Part 3: Loops
  document.getElementById("countdownBtn").addEventListener("click", () => {
    const list = document.getElementById("countdownList");
    list.innerHTML = ""; // clear previous results
  
    // countdown using a for loop
    for (let i = 5; i >= 1; i--) {
      const li = document.createElement("li");
      li.textContent = i;
      list.appendChild(li);
    }
  
    // another loop example with while
    let j = 1;
    while (j <= 3) {
      const li = document.createElement("li");
      li.textContent = `Extra count: ${j}`;
      list.appendChild(li);
      j++;
    }
  });
  
  //  Part 4: DOM Manipulation
  document.getElementById("toggleTextBtn").addEventListener("click", () => {
    const text = document.getElementById("toggleText");
    text.style.display = (text.style.display === "none") ? "block" : "none";
  });
  
  document.getElementById("addItemBtn").addEventListener("click", () => {
    const ul = document.getElementById("dynamicList");
    const li = document.createElement("li");
    li.textContent = `New item ${ul.children.length + 1}`;
    ul.appendChild(li);
  });
  
  // Bonus: Change background color on click
  document.body.addEventListener("dblclick", () => {
    document.body.style.background = 
      document.body.style.background === "lightyellow" ? "#f4f6f8" : "lightyellow";
  });
  