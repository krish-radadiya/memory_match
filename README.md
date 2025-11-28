📱 Memory Match Game (Flutter)

A polished and responsive memory card matching game built using Flutter + GetX, designed to test logic, animation handling, and UI consistency.

🚀 Features
🎮 Gameplay

Smooth 3D flip animation

Correct match detection

Automatic reset for wrong matches

Attempt limit with Game Over

Win screen with replay option

🧠 State Management

GetX used for lightweight and safe reactive updates

Only affected card widgets rebuild, improving performance

Game reset safely clears timers, states, and animations

🎨 UI / UX

Fully responsive with Sizer

Gradient cards with fruit icons

Name label under each fruit

Animated flip effect with depth & shadow

Clean puzzle-game layout

🔒 Logic Safety

Flip actions are blocked while comparing cards

isBusy prevents rapid tapping and race conditions

All animations triggered after frame build to avoid GetX errors

Dialogs (Win/Game Over) opened safely outside build context

🎞️ Animation Approach

Card flip uses AnimationController + Transform.rotateY

Lift effect added using sin(angle) for 3D feel

Back and front designed separately and swapped based on angle

High-quality fruit images loaded with fallback safety


