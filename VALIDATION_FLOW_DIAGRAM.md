# Profile Validation Flow Diagram

## Visual Representation of the Validation Process

---

## 📊 Complete Validation Flow

```mermaid
graph TB
    Start[User Opens Edit Profile] --> ViewMode[View Mode - Read Only]
    ViewMode --> TapEdit[User Taps Edit Button]
    TapEdit --> EditMode[Edit Mode Enabled]
    
    EditMode --> TypeInput[User Types in Field]
    TypeInput --> OnChanged{onChanged Triggered}
    
    OnChanged --> CallHandler[_onFieldChanged Called]
    CallHandler --> SwitchCheck{Which Field?}
    
    SwitchCheck -->|Name| ValidateName[_validateName]
    SwitchCheck -->|Email| ValidateEmail[_validateEmail]
    SwitchCheck -->|Phone| ValidatePhone[_validatePhone]
    
    ValidateName --> NameCheck{Contains Numbers?}
    NameCheck -->|Yes| NameError[Set Error: Numbers not allowed]
    NameCheck -->|No| NameValid[Valid ✓]
    
    ValidateEmail --> EmailCheck1{Has @?}
    EmailCheck1 -->|No| EmailError1[Set Error: Must contain @]
    EmailCheck1 -->|Yes| EmailCheck2{Has Domain?}
    EmailCheck2 -->|No| EmailError2[Set Error: Must have domain]
    EmailCheck2 -->|Yes| EmailCheck3{Format Valid?}
    EmailCheck3 -->|No| EmailError3[Set Error: Invalid format]
    EmailCheck3 -->|Yes| EmailValid[Valid ✓]
    
    ValidatePhone --> PhoneCheck1{Has Letters?}
    PhoneCheck1 -->|Yes| PhoneError1[Set Error: No letters allowed]
    PhoneCheck1 -->|No| PhoneCheck2{Exactly 10 Digits?}
    PhoneCheck2 -->|No| PhoneError2[Set Error: Must be 10 digits]
    PhoneCheck2 -->|Yes| PhoneValid[Valid ✓]
    
    NameError --> UpdateState[setState - Update UI]
    EmailError1 --> UpdateState
    EmailError2 --> UpdateState
    EmailError3 --> UpdateState
    PhoneError1 --> UpdateState
    PhoneError2 --> UpdateState
    
    NameValid --> ClearError[Remove Error Message]
    EmailValid --> ClearError
    PhoneValid --> ClearError
    
    UpdateState --> ShowError[Display Red Error Text]
    ClearError --> HideError[Hide Error Text]
    
    ShowError --> UserFixes[User Fixes Input]
    HideError --> UserFixes
    
    UserFixes --> TypeInput
    
    EditMode --> TapSave[User Taps Save]
    TapSave --> FinalValidate[Final Validation Check]
    
    FinalValidate --> CheckAllFields{All Fields Valid?}
    CheckAllFields -->|No Errors| SaveSuccess[Save Data to Database]
    CheckAllFields -->|Has Errors| ShowAllErrors[Show All Error Messages]
    
    SaveSuccess --> ShowSuccess[Green Success SnackBar]
    ShowSuccess --> ExitEdit[Exit Edit Mode]
    
    ShowAllErrors --> FixErrors[User Must Fix Errors]
    FixErrors --> TypeInput
    
    ExitEdit --> ViewMode
```

---

## 🔍 Detailed Field-Specific Flows

### Name Field Validation Flow

```mermaid
graph LR
    A[User Types in Name Field] --> B{Input Formatter Check}
    B -->|Try to type 0-9| C[Blocked by FilteringTextInputFormatter]
    B -->|Type letters/spaces| D[Character Appears]
    
    D --> E{onChanged Triggered}
    E --> F[_validateName Called]
    
    F --> G{Check: Contains Numbers?}
    G -->|Yes via paste| H[Return false]
    G -->|No| I{Check: Length >= 2?}
    
    I -->|No| J[Return false]
    I -->|Yes| K{Check: Length <= 50?}
    
    K -->|No| L[Return false]
    K -->|Yes| M{Check: Has Letters?}
    
    M -->|No| N[Return false]
    M -->|Yes| O[Return true - VALID]
    
    H --> P[Set Error Message]
    J --> P
    L --> P
    N --> P
    O --> Q[Clear Error Message]
    
    P --> R[Display: "Numbers are not allowed..."]
    Q --> S[No Error Shown]
```

### Email Field Validation Flow

```mermaid
graph TD
    Start[User Types in Email Field] --> Layer1{Layer 1: Contains @?}
    
    Layer1 -->|No| Error1[Error: Must contain @ symbol]
    Layer1 -->|Yes| Layer2{Layer 2: Contains . ?}
    
    Layer2 -->|No| Error2[Error: Must contain domain]
    Layer2 -->|Yes| Layer3{@ Before Last . ?}
    
    Layer3 -->|No| Error3[Error: Invalid format]
    Layer3 -->|Yes| Layer4{Text Before @?}
    
    Layer4 -->|No| Error4[Error: Must have text before @]
    Layer4 -->|Yes| Layer5{Text After @?}
    
    Layer5 -->|No| Error5[Error: Must have domain after @]
    Layer5 -->|Yes| Layer6{TLD Length >= 2?}
    
    Layer6 -->|No| Error6[Error: Domain extension too short]
    Layer6 -->|Yes| Layer7{RegExp Pattern Match?}
    
    Layer7 -->|No| Error7[Error: Please enter valid email]
    Layer7 -->|Yes| Valid[VALID ✓ - No Error]
    
    Error1 --> Display[Show Error Message]
    Error2 --> Display
    Error3 --> Display
    Error4 --> Display
    Error5 --> Display
    Error6 --> Display
    Error7 --> Display
    Valid --> Clear[Clear Error Message]
```

### Phone Number Field Validation Flow

```mermaid
graph LR
    A[User Types in Phone Field] --> B{Input Formatter}
    
    B -->|Try to type a-z/A-Z| C[Blocked - Character Won't Appear]
    B -->|Type 0-9/+| D[Digit Appears]
    B -->|Type other chars| E[Blocked]
    
    D --> F{Length Check}
    F -->|Reach 10 digits| G[Stop Accepting Input]
    F -->|Less than 10| H[Continue Accepting]
    
    H --> I{onChanged Triggered}
    I --> J[_validatePhone Called]
    
    J --> K{Clean Input}
    K --> L{Check: Has Letters?}
    
    L -->|Yes bypass| M[Return false]
    L -->|No| N{Check: Only Digits?}
    
    N -->|No| M
    N -->|Yes| O{Count Digits}
    
    O -->|Not 10| P[Return false]
    O -->|Exactly 10| Q[Return true - VALID]
    
    M --> R[Set Error with Current Count]
    P --> R
    
    R --> S[Show: Must be 10 digits current: X]
    Q --> T[Clear Error]
```

---

## 💾 Save Process Flow

```mermaid
graph TD
    Start[User Taps Save Button] --> Validate1[Call _saveProfile]
    
    Validate1 --> CheckForm{Form Key Validates?}
    CheckForm -->|No| ShowFormErrors[Show Form-Level Errors]
    CheckForm -->|Yes| CheckName{Name Valid?}
    
    CheckName -->|No| SetNameErr[Set Name Error State]
    CheckName -->|Yes| CheckEmail{Email Valid?}
    
    CheckEmail -->|No| SetEmailErr[Set Email Error State]
    CheckEmail -->|Yes| CheckPhone{Phone Valid?}
    
    CheckPhone -->|No| SetPhoneErr[Set Phone Error State]
    CheckPhone -->|Yes| AllValid{Any Errors?}
    
    SetNameErr --> HasErrors[Has Errors = true]
    SetEmailErr --> HasErrors
    SetPhoneErr --> HasErrors
    
    HasErrors --> AllValid
    AllValid -->|Yes Errors| ShowSnackBar[Red SnackBar: Fix Errors]
    AllValid -->|No Errors| SaveData[Update Profile Data]
    
    SaveData --> ClearState[Clear Validation State]
    ClearState --> ExitEdit[Exit Edit Mode]
    
    ExitEdit --> ShowSuccess[Green Success SnackBar]
    ShowSuccess --> End[End - Profile Updated]
    
    ShowFormErrors --> End
    ShowSnackBar --> End
```

---

## 🎯 Real-Time Error Display Flow

```mermaid
sequenceDiagram
    participant U as User
    participant TF as TextFormField
    participant OC as onChanged Handler
    participant VAL as Validator
    participant STATE as setState
    participant UI as UI Display
    
    U->>TF: Types "John123"
    TF->>OC: Triggers with value "John123"
    OC->>VAL: Calls _validateName("John123")
    VAL->>VAL: Checks RegExp [0-9]
    VAL-->>OC: Returns false (invalid)
    OC->>STATE: Updates _fieldErrorMessages['name']
    STATE->>STATE: Sets error message
    STATE->>UI: Rebuilds Widget
    UI-->>U: Shows red error text
    
    U->>TF: Deletes "123"
    TF->>OC: Triggers with value "John"
    OC->>VAL: Calls _validateName("John")
    VAL->>VAL: Checks all rules
    VAL-->>OC: Returns true (valid)
    OC->>STATE: Removes error from map
    STATE->>UI: Rebuilds Widget
    UI-->>U: Error disappears
```

---

## 🏗️ Architecture Diagram

```mermaid
graph TB
    subgraph "UI Layer"
        A[ProfileScreen Widget]
        B[TextFormField Widgets]
        C[Error Display Area]
    end
    
    subgraph "State Management"
        D[_fieldValidationState Map]
        E[_fieldErrorMessages Map]
        F[TextEditingController]
    end
    
    subgraph "Validation Logic"
        G[_validateName Method]
        H[_validateEmail Method]
        I[_validatePhone Method]
    end
    
    subgraph "Error Messages"
        J[_getNameError Method]
        K[_getEmailError Method]
        L[_getPhoneError Method]
    end
    
    subgraph "Input Control"
        M[FilteringTextInputFormatter]
        N[LengthLimitingTextInputFormatter]
    end
    
    A --> B
    B --> C
    B --> D
    B --> E
    B --> F
    
    B --> G
    B --> H
    B --> I
    
    G --> J
    H --> K
    I --> L
    
    B --> M
    B --> N
    
    D --> C
    E --> C
```

---

## 📱 User Journey Map

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER JOURNEY: EDIT PROFILE                   │
└─────────────────────────────────────────────────────────────────┘

Phase 1: VIEW MODE
┌──────────────┐
│ User opens   │
│ profile      │
│ screen       │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Sees read-   │
│ only info    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Decides to   │
│ edit         │
└──────┬───────┘
       │
       └──────────────────┐
                          │
                          ▼
Phase 2: ENABLE EDIT     │
┌──────────────┐          │
│ Taps Edit    │◄─────────┘
│ button       │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Fields      │
│ become      │
│ editable    │
└──────┬───────┘
       │
       └──────────────────┐
                          │
                          ▼
Phase 3: INPUT & ERROR   │
┌──────────────┐          │
│ Types in     │◄─────────┘
│ name field   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Types        │
│ "John123"    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ RED ERROR    │
│ APPEARS:     │
│ "Numbers are │
│ not allowed" │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ User notices │
│ error        │
└──────┬───────┘
       │
       └──────────────────┐
                          │
                          ▼
Phase 4: CORRECTION      │
┌──────────────┐          │
│ Deletes      │◄─────────┘
│ "123"        │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ ERROR        │
│ DISAPPEARS   │
│ (real-time)  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Continues    │
│ typing valid │
│ data         │
└──────┬───────┘
       │
       │ (repeat for email, phone)
       ▼
Phase 5: SAVE ATTEMPT
┌──────────────┐
│ All fields   │
│ look valid   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Taps "Save   │
│ Changes"     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ System runs  │
│ final        │
│ validation   │
└──────┬───────┘
       │
       ├─────────────┬────────────┐
       │             │            │
       ▼             ▼            ▼
┌──────────┐  ┌──────────┐ ┌──────────┐
│ ALL      │  │ SOME     │ │ ALL      │
│ VALID ✓  │  │ INVALID  │ │ INVALID  │
└────┬─────┘  └────┬─────┘ └────┬─────┘
     │             │             │
     ▼             ▼             ▼
┌──────────┐  ┌──────────┐ ┌──────────┐
│ GREEN    │  │ RED      │ │ RED      │
│ SUCCESS  │  │ SNACKBAR │ │ SNACKBAR │
│ MESSAGE  │  │ + errors │ │ + errors │
└────┬─────┘  └────┬─────┘ └────┬─────┘
     │             │             │
     ▼             ▼             ▼
┌──────────┐  ┌──────────┐ ┌──────────┐
│ Exit     │  │ User     │ │ User     │
│ Edit     │  │ fixes    │ │ fixes    │
│ Mode     │  │ errors   │ │ errors   │
└────┬─────┘  └────┬─────┘ └────┬─────┘
     │             │             │
     ▼             ▼             ▼
┌──────────┐  ┌──────────┐ ┌──────────┐
│ Profile  │  │ Tries    │ │ Tries    │
│ Updated! │  │ Save     │ │ Save     │
└──────────┘  └──────────┘ └──────────┘
```

---

## 🔄 State Management Cycle

```mermaid
graph LR
    A[Initial State] --> B[User Input]
    B --> C{Input Valid?}
    
    C -->|Yes| D[Valid State]
    C -->|No| E[Invalid State]
    
    D --> F[Clear Error Message]
    E --> G[Set Error Message]
    
    F --> H[setState Called]
    G --> H
    
    H --> I[Widget Rebuilds]
    I --> J[UI Updates]
    
    J --> K{User Continues?}
    K -->|Yes| B
    K -->|No - Save| L[Final Validation]
    
    L --> M{All Valid?}
    M -->|Yes| N[Save Success]
    M -->|No| O[Show All Errors]
    
    N --> P[Exit Edit Mode]
    O --> B
```

---

## 🎨 Visual Feedback States

```
┌────────────────────────────────────────────────────┐
│                FIELD STATES                        │
└────────────────────────────────────────────────────┘

STATE 1: EMPTY (Required Field)
┌─────────────────────────────────┐
│ Full Name                       │
│                                 │
│ Enter your full name            │
│                                 │
└─────────────────────────────────┘
       │
       ▼ (user focuses)
┌─────────────────────────────────┐
│ Full Name                       │
│ │                               │
│                                 │
│                                 │
└─────────────────────────────────┘

STATE 2: TYPING INVALID (Real-Time Error)
┌─────────────────────────────────┐
│ Full Name                       │
│ John123                         │
│                                 │
│ Numbers are not allowed in the  │
│ name field.                     │
└─────────────────────────────────┘
       │
       ▼ (user deletes numbers)
┌─────────────────────────────────┐
│ Full Name                       │
│ John                            │
│                                 │
│                                 │
└─────────────────────────────────┘

STATE 3: VALID (No Error)
┌─────────────────────────────────┐
│ Full Name                  ✓    │
│ John Doe                        │
│                                 │
│                                 │
└─────────────────────────────────┘

STATE 4: SAVE ATTEMPT WITH ERRORS
┌─────────────────────────────────┐
│ Full Name                       │
│ John                            │
│ Name must be at least 2 chars   │
├─────────────────────────────────┤
│ Email Address                   │
│ userexample.com                 │
│ Email must contain '@' symbol   │
├─────────────────────────────────┤
│ Phone Number                    │
│ 12345                           │
│ Must be exactly 10 digits       │
│ (current: 5)                    │
└─────────────────────────────────┘
       │
       ▼ (user fixes all)
┌─────────────────────────────────┐
│ Full Name                  ✓    │
│ John Doe                        │
├─────────────────────────────────┤
│ Email Address              ✓    │
│ john@example.com                │
├─────────────────────────────────┤
│ Phone Number               ✓    │
│ 1234567890                      │
└─────────────────────────────────┘
       │
       ▼ (tap save)
┌─────────────────────────────────┐
│ ✓ Profile updated successfully! │
│                      [UNDO]     │
└─────────────────────────────────┘
```

---

## 📋 Error Message Decision Tree

```mermaid
graph TD
    Start[Field Value Changed] --> FieldType{Which Field?}
    
    %% NAME BRANCH
    FieldType -->|Name| NameEmpty{Is Empty?}
    NameEmpty -->|Yes| NameMsg1["Name is required"]
    NameEmpty -->|No| NameHasNum{Has Numbers?}
    NameHasNum -->|Yes| NameMsg2["Numbers are not allowed..."]
    NameHasNum -->|No| NameTooShort{Length < 2?}
    NameTooShort -->|Yes| NameMsg3["At least 2 characters"]
    NameTooShort -->|No| NameTooLong{Length > 50?}
    NameTooLong -->|Yes| NameMsg4["Cannot exceed 50 chars"]
    NameTooLong -->|No| NameValid[✓ Valid - No Message]
    
    %% EMAIL BRANCH
    FieldType -->|Email| EmailEmpty{Is Empty?}
    EmailEmpty -->|Yes| EmailMsg1["Email is required"]
    EmailEmpty -->|No| EmailNoAt{No '@'?}
    EmailNoAt -->|Yes| EmailMsg2["Must contain '@'"]
    EmailNoAt -->|No| EmailNoDot{No '.'?}
    EmailNoDot -->|Yes| EmailMsg3["Must contain domain"]
    EmailNoDot -->|No| EmailFormat{Invalid Format?}
    EmailFormat -->|Yes| EmailMsg4["Please enter valid email"]
    EmailFormat -->|No| EmailValid[✓ Valid - No Message]
    
    %% PHONE BRANCH
    FieldType -->|Phone| PhoneEmpty{Is Empty?}
    PhoneEmpty -->|Yes| PhoneMsg1["Phone is required"]
    PhoneEmpty -->|No| PhoneHasLetters{Has Letters?}
    PhoneHasLetters -->|Yes| PhoneMsg2["No letters allowed"]
    PhoneHasLetters -->|No| PhoneNot10{Not 10 Digits?}
    PhoneNot10 -->|Yes| PhoneMsg3["Must be 10 digits current: X"]
    PhoneNot10 -->|No| PhoneValid[✓ Valid - No Message]
    
    NameMsg1 --> Display[Display Error Message]
    NameMsg2 --> Display
    NameMsg3 --> Display
    NameMsg4 --> Display
    
    EmailMsg1 --> Display
    EmailMsg2 --> Display
    EmailMsg3 --> Display
    EmailMsg4 --> Display
    
    PhoneMsg1 --> Display
    PhoneMsg2 --> Display
    PhoneMsg3 --> Display
    
    NameValid --> Clear[Clear Error Message]
    EmailValid --> Clear
    PhoneValid --> Clear
```

---

This comprehensive flow documentation shows every aspect of how the validation system works visually!
