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

https://github.com/user-attachments/assets/627ba8e8-57b6-455e-a109-d61ddb610893 

https://github.com/user-attachments/assets/96eeb1d0-9de0-4407-861d-fffed27e2b75


<img src="https://github.com/user-attachments/assets/efcc9c2e-9362-4f06-925d-0ba79f51ccbc" width="250">
<img src="https://github.com/user-attachments/assets/a5e3af4a-63a2-4fd4-b47c-503b8a68b260" width="250">
<img src="https://github.com/user-attachments/assets/0394e040-2311-40d3-9d27-0e2a664e53ff" width="250">
<img src="https://github.com/user-attachments/assets/631067a7-7414-416e-8601-e1faa7af1e41" width="250">
<img src="https://github.com/user-attachments/assets/aa7cb4aa-66d5-4370-9c8d-288ff4c784f6" width="250">






