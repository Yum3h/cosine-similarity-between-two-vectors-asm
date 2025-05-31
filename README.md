# Exploring MIPS Assembly Using MARS Simulator

## Course Information
- **Course:** CE201 – Computer Architecture and Organization
  
---

## Objective
This project deepens understanding of MIPS assembly and computer architecture by implementing a cosine similarity calculator using the MARS simulator. Key skills exercised include:
- MIPS floating-point operations (`$f0–$f31`)
- Modular procedure implementation
- Memory management and stack usage
- Register conventions
- Full testing and debugging

---

## Theory

MIPS (Microprocessor without Interlocked Pipeline Stages) is a RISC architecture commonly used for educational purposes. This project implements the cosine similarity between two vectors using:

\[
cos⁡θ=(a^T b)/‖a‖‖b‖ 
\]

Where:
- `a ⋅ b` is the dot product
- `‖a‖` and `‖b‖` are the Euclidean norms

MARS (MIPS Assembler and Runtime Simulator) was used for execution and testing.

---

## Design

Although no Python code was written, I used NumPy's algorithmic approach as a conceptual guide. Key steps:
- Manual translation of NumPy logic into MIPS
- Use of floating-point arithmetic and procedures
- Flowchart-based logic (outlined in the report)

---

## Implementation

### Main Procedures
- `main`: Coordinates program flow
- `DotProduct`: Calculates a·b
- `EuclideanNorm`: Computes vector norms
- `CosineSimilarity`: Uses previous two results

### Key Features
- Secure input parsing and validation
- Floating-point arithmetic with instructions like `add.s`, `mul.s`, `sqrt.s`
- Stack-based register saving
- Clean, commented code

---

## Debugging and Testing

### Testing Coverage:
- Validated mathematical results vs Python outputs
- Handled invalid input: letters, symbols, malformed floats
- Special cases: zero vectors, orthogonal vectors, etc.

### Example Tests:
| Vector A         | Vector B         | Notes                      |
|------------------|------------------|----------------------------|
| [1,2,3,4,5]       | [1,1,1,1,1]       | High similarity            |
| [12.2,1,1,1,1]    | [1,1,1,-1,1]      | Mixed signs                |
| [0,0,0,0,0]       | [1,1,1,1,1]       | Zero vector handled safely |

All results matched expected values from Python (NumPy).

---

## Conclusion and Future Improvements

### Achievements
- Complete cosine similarity program in MIPS
- Secure and robust input handling
- Modular, reusable procedure design
- Clean memory/register usage

### Limitations
- Vector size restricted to 5–10 (per assignment)
- No formatted float output
- Static memory usage

### Future Work
- Dynamic memory support
- Enhanced output formatting
- Support for matrix operations

---

## Contributions

Claude Sonnet 4 provided strong initial module structures and logic based on the NumPy approach but required manual adjustments for precision and adherence to MIPS/MARS constraints.

ChatGPT helped with:
- Debugging logical/semantic errors
- Explaining register and memory behavior
- Refining procedure flow and program structure

Both tools supported the learning process by accelerating code development and enhancing understanding.

---

## Files

- `cosine_similarity.asm` – Full MIPS source code  

---

## How to Run

1. Open `cosine_similarity.asm` in [MARS simulator](http://courses.missouristate.edu/kenvollmar/mars/).
2. Assemble and run the program.
3. Follow prompts to enter vector size and values.
4. Final cosine similarity result is printed and stored at memory address `0x10010080`.

---

