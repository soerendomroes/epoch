/*
 * generated by Xtext 2.25.0
 */
package org.lflang.ui.wizard

import org.eclipse.core.runtime.Status
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.xtext.ui.util.PluginProjectFactory
import org.eclipse.xtext.ui.wizard.template.IProjectGenerator
import org.eclipse.xtext.ui.wizard.template.IProjectTemplateProvider
import org.eclipse.xtext.ui.wizard.template.ProjectTemplate

import static org.eclipse.core.runtime.IStatus.*

/**
 * Create a list with all project templates to be shown in the template new project wizard.
 * 
 * Each template is able to generate one or more projects. Each project can be configured such that any number of files are included.
 */
class LFProjectTemplateProvider implements IProjectTemplateProvider {
	override getProjectTemplates() {
		#[new HelloWorldProject, new InteractiveProject, new WebServerProject]
	}
}

@ProjectTemplate(label="Hello World", icon="project_template.png", description="<p><b>Hello World</b></p>
<p>Print \"Hello world!\" in a target language of choice.</p>")
final class HelloWorldProject {
	//val advanced = check("Advanced:", false)
	val config = group("Configuration")
	val target = combo("Target:", #["C", "C++", "Python", "TypeScript"], "The target language to compile down to", config)
	//val path = text("Package:", "mydsl", "The package path to place the files in", advancedGroup)
    //target.enabled = true
    
//	override protected updateVariables() {
//		name.enabled = advanced.value
//		path.enabled = advanced.value
//		if (!advanced.value) {
//			name.value = "Xtext"
//			path.value = "lf"
//		}
//	}

//	override protected validate() {
//		if (path.value.matches('[a-z][a-z0-9_]*(/[a-z][a-z0-9_]*)*'))
//			null
//		else
//			new Status(ERROR, "Wizard", "'" + path + "' is not a valid package name")
//	}

	override generateProjects(IProjectGenerator generator) {
		generator.generate(new PluginProjectFactory => [
			projectName = projectInfo.projectName
			location = projectInfo.locationPath
			projectNatures += #[XtextProjectHelper.NATURE_ID] // JavaCore.NATURE_ID, "org.eclipse.pde.PluginNature", 
			builderIds += #[XtextProjectHelper.BUILDER_ID] // JavaCore.BUILDER_ID, 
			folders += "src"
			addFile('''src/HelloWorld.lf''', '''
				/**
				 * Print "Hello World!" in «target».
				 */
				«IF target.value.equals("C")»
				target C
				
				main reactor {
				    reaction(startup) {=
				        // Using a thread-safe print function provided by the runtime.
				        info_print("Hello World!");
				    =}
				}
				«ELSEIF target.value.equals("C++")»
                target Cpp
                
                main reactor {
                    reaction(startup) {=
                        std::cout << "Hello World!";
                    =}
                }
                «ELSEIF target.value.equals("Python")»
                target Python
                
                main reactor {
                    reaction(startup) {=
                        print("Hello World!")
                    =}
                }
                «ELSEIF target.value.equals("TypeScript")»
                target TypeScript
                
                main reactor {
                    reaction(startup) {=
                        console.log("Hello World!")
                    =}
                }
				«ENDIF»
			''')
		])
	}
}

@ProjectTemplate(label="Interactive", icon="project_template.png", description="<p><b>Interactive</b></p>
<p>Simulate sensor input through key strokes.</p>")
final class InteractiveProject {
    //val advanced = check("Advanced:", false)
    val config = group("Configuration")
    val target = combo("Target:", #["C"], "The target language to compile down to", config)
    
    override generateProjects(IProjectGenerator generator) {
        generator.generate(new PluginProjectFactory => [
            projectName = projectInfo.projectName
            location = projectInfo.locationPath
            projectNatures += #[XtextProjectHelper.NATURE_ID]
            builderIds += #[XtextProjectHelper.BUILDER_ID] 
            folders += #["src", "src/include"]
            addFile("src/Interactive.lf", '''
                /**
                 * Simple demonstration of the sensor simulator (used in the Rhythm examples).
                 * This has no audio output, but just tests the ncurses interface.
                 */
                target «target» {
                    threads: 2,
                    cmake-include: ["ncurses-cmake-extension.txt", "sensor_simulator.cmake"], // Adds support for ncurses
                    files: [
                            "/lib/C/util/sensor_simulator.c", 
                            "/lib/C/util/sensor_simulator.h",
                            "/lib/C/util/sensor_simulator.cmake",
                            "include/ncurses-cmake-extension.txt"
                        ]
                };
                preamble {=
                    #include "sensor_simulator.h"
                    char* messages[] = {"Hello", "World"};
                    int num_messages = 2;
                =}
                main reactor {
                    timer t(0, 1 sec);
                    timer r(0, 2 sec);
                    physical action key:char*;
                    reaction(startup) -> key {=
                        info_print("Starting sensor simulator.");
                        start_sensor_simulator(messages, num_messages, 16, NULL, LOG_LEVEL_INFO);
                        register_sensor_key('\0', key);
                   =}
                    reaction(t) {=
                        show_tick("*");
                    =}
                    reaction(r) {=
                        info_print("Elapsed logical time: %lld.", get_elapsed_logical_time());
                        show_tick(".");
                    =}
                    reaction(key) {=
                        info_print("You typed '%s' at elapsed time %lld.", key->value, get_elapsed_logical_time());
                    =}
                }
            ''')
            addFile("src/include/ncurses-cmake-extension.txt", '''
                find_package(Curses REQUIRED) # Finds the lncurses library
                include_directories(${CURSES_INCLUDE_DIR}) # "The include directories needed to use Curses"
                target_link_libraries( ${LF_MAIN_TARGET} ${CURSES_LIBRARIES} ) # Links the Curses library
            ''')
        ])
    }
}

@ProjectTemplate(label="WebServer", icon="project_template.png", description="<p><b>Web Server</b></p>
<p>A simple web server implemented using TypeScript.</p>")
final class WebServerProject {
    //val advanced = check("Advanced:", false)
    val config = group("Configuration")
    val target = combo("Target:", #["TypeScript"], "The target language to compile down to", config)
    
    override generateProjects(IProjectGenerator generator) {
        generator.generate(new PluginProjectFactory => [
            projectName = projectInfo.projectName
            location = projectInfo.locationPath
            projectNatures += #[XtextProjectHelper.NATURE_ID]
            builderIds += #[XtextProjectHelper.BUILDER_ID] 
            folders += #["src"]
            addFile("src/WebServer.lf", '''
                target «target» {
                    keepalive : true
                };
                
                main reactor {
                    preamble {=
                        import * as http from "http"
                    =}
                    state server:{=http.Server | undefined=}({=undefined=});
                    physical action serverRequest:{= [http.IncomingMessage, http.ServerResponse] =};
                    reaction (startup) -> serverRequest {=
                        let options = {};
                        server = http.createServer(options, (req : http.IncomingMessage, res : http.ServerResponse) => {
                            // Generally, browsers make two requests; the first is for favicon.ico.
                            // See https://stackoverflow.com/questions/11961902/nodejs-http-createserver-seems-to-call-twice
                            if (req.url != "/favicon.ico") {
                                actions.serverRequest.schedule(0, [req, res])
                            }
                        }).listen(8000);
                        console.log("Started web server at http://localhost:8000/")
                    =}
                    reaction (serverRequest) {=
                        let requestArray = serverRequest;
                        if (requestArray) {
                            let req = requestArray[0];
                            let res = requestArray[1];
                            res.writeHead(200);
                            res.end("Hello world!\n");
                        }
                    =}
                    reaction (shutdown) {=
                        if (server) {
                            server.close();
                        }
                    =} 
                }
            ''')
        ])
    }
}

