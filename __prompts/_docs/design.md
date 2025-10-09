# 📘 US_DESIGN_CODEX_RULES.md (English Version)

## 🚨 CODEX GUIDELINES & PRINCIPLES

This document defines all necessary design rules for implementing the UI/UX of `Us`, a **Flutter cross-platform app**. **All code generation and UI implementation must prioritize and adhere to the design tokens, component specifications, and UX principles outlined below.**

### CORE PRINCIPLES (Design Principles)

| Principle       | Rule for AI Generation                                                                                                                                                                                             |
| :-------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Clarity**     | Eliminate unnecessary embellishments (excessive shadows, double borders, etc.) when structuring the UI. Information hierarchy must be clearly separated according to the **`Typography`** and **`Spacing`** rules. |
| **Connection**  | Use the **Primary Green** color and **`Haptic Feedback`** during user interactions (button clicks, data saving) to visually and physically express a sense of positive connection.                                 |
| **Consistency** | All components (buttons, input fields, cards) must default to **`Corner Radius: 12px`** and maintain visual consistency across states (Default, Disabled, Error).                                                  |
| **Inclusion**   | All interactive elements must adhere to the **`Touch Area`** rule and meet the contrast ratio standards in the **`Accessibility`** section.                                                                        |

---

## 1. DESIGN TOKENS (Style Variables)

**When implementing Flutter code, reference the design tokens below via `ThemeData` or constant classes, instead of using hard-coded values.**

### 1.1. Color Tokens (`AppColors`)

| Token Name                 | Hex       | Usage Rule                                                      |
| :------------------------- | :-------- | :-------------------------------------------------------------- |
| `color_primary_500`        | `#10B981` | Used for main actions, focus states, and active navigation tabs |
| `color_primary_600`        | `#059669` | Used for button `:active` state (for $100\text{ms}$)            |
| `color_background_default` | `#F9FAFB` | Default background color for all pages                          |
| `color_gray_300`           | `#D1D5DB` | Default border for input fields and dividers                    |
| `color_text_body`          | `#4B5563` | Used for body text, including `Body1`, `Body2`, `H1`, and `H2`  |
| `color_text_caption`       | `#9CA3AF` | Used for `Caption` and disabled text                            |
| `color_error`              | `#FF4D7E` | Used for input error states and warning messages                |
| `color_warning`            | `#FBBF24` | Used for cautionary alerts and incomplete status indicators     |

### 1.2. Spacing Tokens (`AppSpacing`)

**All margins and padding must use the tokens below, which are based on a 4px grid.**

| Token Name   | Value (dp) | Usage Rule                                                    |
| :----------- | :--------- | :------------------------------------------------------------ |
| `spacing_xs` | **8.0**    | Minimum spacing between icons and text                        |
| `spacing_m`  | **16.0**   | Default spacing between components, screen horizontal padding |
| `spacing_l`  | **24.0**   | Separation between section titles and content blocks          |
| `spacing_xl` | **32.0**   | Separation between major blocks on screen                     |

---

## 2. COMPONENTS & LAYOUT RULES

### 2.1. Component: Button (`PrimaryButton`, `TextButton`)

- **Size Constraint:** `Height: 48.0 dp`
- **Corner Radius:** `12.0 dp`
- **Accessibility:** Touch area must be **$44.0\text{ dp} \times 44.0\text{ dp}$** or larger
- **Interaction:** On click, change color to **`color_primary_600`** ($\text{100ms}$, `Curves.easeIn`) and include a **Light Haptic Feedback**.
- **Disabled State:** Must use **`color_gray_300`** for the background and **`color_text_caption`** for the text color.

### 2.2. Component: Input Field

- **Default State:** `BorderColor: color_gray_300`
- **Focused/Typing State:** `BorderColor: color_primary_500`. The **cursor color** must be set to **`color_primary_500`**.
- **Error State:** `BorderColor: color_error`. Validation messages must follow the **`Caption`** style and be displayed in **`color_error`**.

### 2.3. Layout & Structure

- **Corner Radius Rule:** Apply **`12.0 dp`** to main UI elements like cards and buttons. Apply **`24.0 dp`** to modals and bottom sheets.
- **Screen Padding:** The horizontal padding of all screens must default to **`spacing_m` (16.0 dp)**.
- **Bottom Navigation Bar:** Height is fixed at **$56.0\text{ dp}$** and must be implemented to include the iOS Safe Area. Active tab icon and text must use **`color_primary_500`**.
- **Iconography:** All icons default to a size of **$24.0\text{ dp}$** and must primarily use the **Material Icons** library.

---

## 3. UX INTERACTION & BEHAVIOR

### 3.1. Motion & Animation (Duration & Easing)

| Behavior               | Duration (ms)      | Easing Curve           | Rule                                                   |
| :--------------------- | :----------------- | :--------------------- | :----------------------------------------------------- |
| **Page Transition**    | **$300\text{ms}$** | **`Curves.easeInOut`** | Page transitions must use a horizontal slide animation |
| **Button Press Scale** | **$100\text{ms}$** | **`Curves.easeIn`**    | Apply scale-down feedback to $0.96$ on button press    |
| **Modal/Sheet Open**   | **$250\text{ms}$** | **`Curves.easeOut`**   | Bottom sheets must appear smoothly from the bottom     |

### 3.2. Feedback & Accessibility

- **Toast Message:** Display centered at the bottom of the screen and must automatically disappear after a **`Duration: 3000ms`**.
- **Error Handling:** Network error messages must be displayed with **`color_error`** text and clearly provide a **retry option** to the user.
- **Contrast:** The color contrast ratio between text and background must **strictly adhere to $4.5:1$ or higher** (WCAG AA).
- **Minimum Text Size:** Text size, including `Caption`, must **not be set below $12\text{px}$**.
