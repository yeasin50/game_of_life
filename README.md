# game_of_life

> Build during the curfew(Bangladesh), thousands of students where killed and got injured.

for more search tag `SaveBangladeshStudent`

[Game concept](https://pi.math.cornell.edu/~lipa/mec/lesson6.html)

- If the cell is alive, then it stays alive if it has either 2 or 3 live neighbors

- If the cell is dead, then it springs to life only in the case that it has 3 live neighbors

![](https://upload.wikimedia.org/wikipedia/commons/e/e5/Gospers_glider_gun.gif)

<details>
 
<summary> User flow</summary>

```puml
@startuml gameOfLife
actor User

User --> (Home)

(Home) --> (PreModel)
(Home) --> (CustomPattern)



note left of (PreModel)
 List of defined models
 - auto fill form
 - can increase the grid size

end note

(PreModel) --> (FiveCellPattern)

note bottom of (FiveCellPattern)
- min space: [4x4]
- clip: none
end note

(PreModel) --> (Glider)

note bottom of (Glider)
- min space: [4x4]
- clip: none
end note

(PreModel) --> (LightWeightSpaceShip)

note bottom of (LightWeightSpaceShip)
- min space: [5x6]
- clip: none
end note

(PreModel) --> (MiddleWeightSpaceShip)

note bottom of (MiddleWeightSpaceShip)
- min space: [7x7]
- clip: none
end note


(CustomPattern) --> (UserForm)


note right of (UserForm)

- user can insert a predefine at a giver offset

end note


(PreModel) --> Simulate
(UserForm) --> Simulate


@enduml
```

</details>
