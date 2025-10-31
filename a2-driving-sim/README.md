COMP 360 ON1 Assignments


## Assignment 2: Interactive Driving Simulation

#### Generate core track
- Sho Okano (track mesh generation, splines, route)
- Aniket Sandhu (hilbert curve)

#### Camera & driving controls
- William created a simple camera input for a first person camera driving experience. Current implementation only moves camera and rotates it using wasd controls. https://www.youtube.com/watch?v=TpU0qGcv1iY
- William created CharacterBody3d with camera attached and reworked movement to add collision to the player, terrain, and track. https://www.youtube.com/watch?v=8Aa7mAwrTRg
- William implemented a 2D steering wheel that turns when the player does
- Sho Okano (set up input handling, acceleration & deceleration, replace 2D steering wheel w 3D)

#### Weather particles: 
- William added smoke/exhaust particles using the particle system, attaching a smoke texture. The smoke trail follows the camera, so driving along, the user will see their path.

#### Ramp + Boost 
- Aniket Sandhu (ramp scene & script)
- Sho Okano (ramp placement algorithm)

#### Lighting: 
- Pragti Duggal implemented the lighting setup in the project to enhance the overall visibility and realism of the racing environment. A DirectionalLight3D was added to simulate sunlight, providing consistent illumination across the track and car.

#### Timer & lap line: 
- Sunny Pak (UI, timer, lap line)
- Sho Okano (integrate with newer track & features)

#### Document debugging/testing with video or wiki
- Sho Okano, [Track generation process (wiki page)](https://github.com/360-g5/assignments/wiki/Sho-%E2%80%90-Track-generation-process)
- Fahim Ar-Rashid Rain Particles-(wiki page)-https://github.com/360-g5/assignments/wiki/%E2%80%9CParticles-won%E2%80%99t-go-beyond-the-map-WIKI-.%E2%80%9D

#### Test & review pull requests
- Sho Okano
- Fahim Ar-Rashid

#### Update project documentation (README.md, kanban board, discord)
- Sho Okano
- Aniket Sandhu
- Fahim Ar-Rashid
- William Craske
- Sunny Pak
- Pragti Duggal
