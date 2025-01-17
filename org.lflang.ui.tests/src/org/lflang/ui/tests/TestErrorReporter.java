/*************
* Copyright (c) 2022, Kiel University.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice,
*    this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice,
*    this list of conditions and the following disclaimer in the documentation
*    and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***************/
package org.lflang.ui.tests;

import static org.junit.Assert.assertEquals;

import java.nio.file.Path;

import org.eclipse.emf.ecore.EObject;
import org.lflang.DefaultErrorReporter;
import org.lflang.FileConfig;

/**
 * Error reporter that asserts the absence of errors.
 * 
 * @author Alexander Schulz-Rosengarten
 */
public class TestErrorReporter extends DefaultErrorReporter {

    public TestErrorReporter(FileConfig fc) {
    }
    public TestErrorReporter() {
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public String reportError(String message) {
        var s = super.reportError(message);
        assertEquals("Error occured during code generation!", "", message);
        return s;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String reportError(EObject object, String message) {
        var s = super.reportError(object, message);
        assertEquals("Error occured during code generation!", "", message);
        return s;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String reportError(Path file, Integer line, String message) {
        var s = super.reportError(file, line, message);
        assertEquals("Error occured during code generation!", "", message);
        return s;
    }

}
