package main

import (
	"github.com/Sirupsen/logrus"
	"github.com/sameo/go-plugins-helpers/runtime"
)

const socketAddress = "/run/docker/plugins/clearcontainers.sock"

type ccPlugin struct {
	path string
	args []string
}

func (p *ccPlugin) Path() runtime.PathResponse {
	return runtime.PathResponse{
		Path: p.path,
	}
}

func (p *ccPlugin) Args() runtime.ArgsResponse {
	return runtime.ArgsResponse{
		Args: p.args,
	}
}

func newCCPlugin(path string, args []string) *ccPlugin {
	return &ccPlugin{
		path: path,
		args: args,
	}
}

func main() {
	p := newCCPlugin("/foo/bar", []string{"foo", "bar"})

	h := runtime.NewHandler(p)
	logrus.Infof("listening on %s", socketAddress)
	logrus.Error(h.ServeUnix(socketAddress, 0))
}
