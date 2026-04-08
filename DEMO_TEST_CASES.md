# Q-picnic demo — test phrases (audio & calendar)

Data source: `Q-picnic database(Sheet1).csv` (products + image paths), `Q-picnic database(Sheet2).csv` (dish → items: **Sandwich**, **Pizza**).  
Backend: `meal_catalog.json` meals `picnic_sandwich`, `picnic_pizza`, plus `bbq_grill`, `salami_sandwich`, `simple_salad`.

## Voice input (Entdecken → microphone)

Speak clearly in **English or German**. Include a **people count** when you want scaled quantities.

### Best-case outputs (scaled bundles)

| Say this (example) | Expected meal | Notes |
|-------------------|---------------|--------|
| “Picnic for **6** people, we’re making **sandwiches**” | `picnic_sandwich` | Sandwich Bread, Leerdammer, Ketchup, Geflügel-Mortadella |
| “**Pizza night** for **4** guests, homemade **pizza**” | `picnic_pizza` | Pizza dough, Ketchup, Mozzarella, Olive oil, Leerdammer |
| “**BBQ** tomorrow for **10** people, **sausages** and **grill**” | `bbq_grill` | Mixed grill bundle |
| “**Salami sandwich** for **2**” | `salami_sandwich` | Salami + bread + cheese |
| “**Green salad** for **8**” | `simple_salad` | Cucumber + tomatoes |

### Short German phrases

- „**Picknick**, **6 Personen**, wir machen **Sandwiches**.“
- „**Pizza** für **4 Personen**, selbst gemacht.“
- „**Grillparty** für **10 Leute**, **Bratwurst** und **Barbecue**.“

### What gets added

- **Voice** (`/api/voice/ingest`): items go into the **Warenkorb** (wishlist queue path).
- **Calendar** (`/api/extract`): items appear as **Vorschläge** on **Entdecken** (not auto-basket).

---

## Calendar event text (title / description)

Use your **primary** calendar. Put the scenario in **title** or **description** (the app concatenates both).

### Strong demo strings (copy-paste)

1. **Sandwich scenario**  
   `Title: Team lunch`  
   `Description: Picnic Saturday — 6 people — cold sandwiches and mortadella.`

2. **Pizza scenario**  
   `Title: Movie night`  
   `Description: Pizza night for 4 — homemade pizza, mozzarella and olive oil.`

3. **BBQ scenario**  
   `Title: Garden party`  
   `Description: BBQ for 12 guests — barbecue, sausages, ketchup.`

4. **Salad-only**  
   `Title: Side dishes`  
   `Description: Green salad for 5 people.`

### Tips

- Include a **number + people/guests/Personen** for scaling.
- Mention **sandwich**, **pizza**, **BBQ/grill**, **salad**, or **salami sandwich** so `meal_id` matches.
- After editing an event, return to the app and open **Entdecken** (or wait for background sync).

---

## Images

Asset paths follow Sheet1 (e.g. `assets/foods/sandwich_bread.jpg`, `pizza_dough.jpg`, `mozarella.jpg`, `olive_oil.jpg`). Ensure those files exist under `qhack-picnic/assets/foods/`.
