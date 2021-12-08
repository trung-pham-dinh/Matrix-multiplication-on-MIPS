#include <iostream>
#include <fstream>
using namespace std;



int main() {
    int nRowA, nColA ,nRowB, nColB;
    cout<<"Size of A(r,c):\n";
    cin>>nRowA>>nColA;
    cout<<"Size of B(r,c):\n";
    cin>>nRowB>>nColB;

    int** A = new int*[nRowA];
    int** B = new int*[nRowB];
    int** result = new int*[nRowA];

    int**  golden_result = new int*[nRowA];

    ifstream fileA("A.txt");
    ifstream fileB("B.txt");
    ifstream fileR("result.txt");

    for(int r = 0; r < nRowA; r++) {
        A[r]  = new int[nColA];
        for(int c = 0; c < nColA; c++) {
            fileA >> A[r][c];
        }
    }
    for(int r = 0; r < nRowB; r++) {
        B[r]  = new int[nColB];
        for(int c = 0; c < nColB; c++) {
            fileB >> B[r][c];
        }
    }
    for(int r = 0; r < nRowA; r++) {
        result[r]  = new int[nColB];
        for(int c = 0; c < nColB; c++) {
            fileR >> result[r][c];
        }
    }

    fileA.close();
    fileB.close();
    fileR.close();

    int numOfDif = 0;
    for(int r = 0; r < nRowA; r++) {
        golden_result[r]  = new int[nColB];
        for(int c = 0; c < nColB; c++) {
            golden_result[r][c] = 0;
            for(int k = 0; k < nColA; k++) {
                golden_result[r][c] += A[r][k] * B[k][c];
            }
            if(golden_result[r][c] != result[r][c]) {
                numOfDif++;
            }
        }
    }

    cout<<"rate of difference: "<<1.0*numOfDif/(nRowA*nColB)<<endl;


    for(int r = 0; r < nRowA; r++) {
        for(int c = 0; c < nColA; c++) {
            cout<<A[r][c]<<' ';
        }cout<<endl;
    }cout<<endl;

    for(int r = 0; r < nRowB; r++) {
        for(int c = 0; c < nColB; c++) {
            cout<<B[r][c]<<' ';
        }cout<<endl;
    }cout<<endl;

    for(int r = 0; r < nRowA; r++) {
        for(int c = 0; c < nColB; c++) {
            cout<<golden_result[r][c]<<' ';
        }cout<<endl;
    }

    return 1;
}
