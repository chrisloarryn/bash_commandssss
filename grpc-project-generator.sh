#!/usr/bin/env bash
# grpc-project-generator.sh
#
# Advanced Go gRPC project generator with hexagonal architecture
# Generates a complete project with Gin, Zap, Buf, Docker, Makefile, and more

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
DEFAULT_MODULE_NAME="github.com/example/grpc-service"
DEFAULT_SERVICE_NAME="user-service"
DEFAULT_GO_VERSION="1.21"
DEFAULT_PORT="8080"
DEFAULT_GRPC_PORT="50051"

# Function to show help
show_help() {
    echo -e "${BLUE}🚀 Go gRPC Project Generator${NC}"
    echo ""
    echo "Usage: $0 --out=<output_path> [options]"
    echo ""
    echo "Required arguments:"
    echo "  --out=PATH             Output directory path"
    echo ""
    echo "Optional arguments:"
    echo "  --module=NAME          Go module name (default: $DEFAULT_MODULE_NAME)"
    echo "  --service=NAME         Service name (default: $DEFAULT_SERVICE_NAME)"
    echo "  --go-version=VERSION   Go version (default: $DEFAULT_GO_VERSION)"
    echo "  --port=PORT           HTTP port (default: $DEFAULT_PORT)"
    echo "  --grpc-port=PORT      gRPC port (default: $DEFAULT_GRPC_PORT)"
    echo "  --no-docker           Skip Docker files generation"
    echo "  --no-makefile         Skip Makefile generation"
    echo "  --no-buf              Skip Buf configuration"
    echo "  --verbose             Verbose output"
    echo "  --help                Show this help"
    echo ""
    echo "Features included:"
    echo "  ✅ Hexagonal Architecture"
    echo "  ✅ gRPC with Protocol Buffers"
    echo "  ✅ Gin HTTP Gateway"
    echo "  ✅ Zap Structured Logging"
    echo "  ✅ gRPC Interceptors"
    echo "  ✅ Buf for Protocol Buffers"
    echo "  ✅ Docker & Docker Compose"
    echo "  ✅ Makefile with common tasks"
    echo "  ✅ Environment Configuration"
    echo "  ✅ Health Checks"
    echo "  ✅ Graceful Shutdown"
    echo "  ✅ Unit & Integration Tests"
    echo ""
    echo "Examples:"
    echo "  $0 --out=./my-service"
    echo "  $0 --out=/tmp/user-service --module=github.com/myorg/user-service --service=user-service"
    echo "  $0 --out=./payment-service --service=payment --port=8081 --grpc-port=50052"
}

# Function to validate requirements
validate_requirements() {
    local missing=()
    
    # Check required tools
    if ! command -v go >/dev/null 2>&1; then
        missing+=("go")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required tools: ${missing[*]}${NC}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    echo -e "${GREEN}✅ All required tools are available${NC}"
}

# Function to create directory structure
create_directory_structure() {
    local output_dir="$1"
    
    echo -e "${BLUE}📁 Creating directory structure...${NC}"
    
    # Root directories
    mkdir -p "$output_dir"
    
    # Application structure (Hexagonal Architecture)
    mkdir -p "$output_dir/cmd/server"
    mkdir -p "$output_dir/cmd/client"
    
    # Internal packages
    mkdir -p "$output_dir/internal/core/domain"
    mkdir -p "$output_dir/internal/core/ports"
    mkdir -p "$output_dir/internal/core/services"
    
    # Adapters
    mkdir -p "$output_dir/internal/adapters/grpc/server"
    mkdir -p "$output_dir/internal/adapters/grpc/client"
    mkdir -p "$output_dir/internal/adapters/http"
    mkdir -p "$output_dir/internal/adapters/repository"
    mkdir -p "$output_dir/internal/adapters/cache"
    
    # Infrastructure
    mkdir -p "$output_dir/internal/infrastructure/config"
    mkdir -p "$output_dir/internal/infrastructure/logger"
    mkdir -p "$output_dir/internal/infrastructure/interceptors"
    mkdir -p "$output_dir/internal/infrastructure/middleware"
    
    # Protocol Buffers
    mkdir -p "$output_dir/api/proto"
    mkdir -p "$output_dir/api/generated/go"
    
    # Configurations
    mkdir -p "$output_dir/configs"
    mkdir -p "$output_dir/deployments/docker"
    mkdir -p "$output_dir/deployments/k8s"
    
    # Scripts and docs
    mkdir -p "$output_dir/scripts"
    mkdir -p "$output_dir/docs"
    
    # Tests
    mkdir -p "$output_dir/test/integration"
    mkdir -p "$output_dir/test/e2e"
    
    echo -e "${GREEN}✅ Directory structure created${NC}"
}

# Function to generate go.mod
generate_go_mod() {
    local output_dir="$1"
    local module_name="$2"
    local go_version="$3"
    
    echo -e "${BLUE}📦 Generating go.mod...${NC}"
    
    cat > "$output_dir/go.mod" << EOF
module $module_name

go $go_version

require (
	github.com/gin-gonic/gin v1.9.1
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.18.1
	go.uber.org/zap v1.26.0
	google.golang.org/grpc v1.59.0
	google.golang.org/protobuf v1.31.0
	github.com/spf13/viper v1.17.0
	github.com/google/uuid v1.4.0
	github.com/stretchr/testify v1.8.4
	go.uber.org/fx v1.20.0
	github.com/golang/mock v1.6.0
	google.golang.org/genproto/googleapis/api v0.0.0-20231106174013-bbf56f31fb17
)

require (
	github.com/golang/protobuf v1.5.3 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	go.uber.org/dig v1.17.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	golang.org/x/net v0.17.0 // indirect
	golang.org/x/sys v0.13.0 // indirect
	golang.org/x/text v0.13.0 // indirect
	google.golang.org/genproto v0.0.0-20231106174013-bbf56f31fb17 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20231106174013-bbf56f31fb17 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
EOF
}

# Function to generate Protocol Buffer definitions
generate_proto_files() {
    local output_dir="$1"
    local service_name="$2"
    
    echo -e "${BLUE}📋 Generating Protocol Buffer files...${NC}"
    
    # Main service proto
    cat > "$output_dir/api/proto/${service_name}.proto" << EOF
syntax = "proto3";

package $service_name.v1;

option go_package = "api/generated/go/${service_name}v1";

import "google/api/annotations.proto";
import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

// $service_name service definition
service ${service_name^}Service {
  // Create a new ${service_name}
  rpc Create${service_name^}(Create${service_name^}Request) returns (Create${service_name^}Response) {
    option (google.api.http) = {
      post: "/v1/${service_name}s"
      body: "*"
    };
  }

  // Get ${service_name} by ID
  rpc Get${service_name^}(Get${service_name^}Request) returns (Get${service_name^}Response) {
    option (google.api.http) = {
      get: "/v1/${service_name}s/{id}"
    };
  }

  // Update ${service_name}
  rpc Update${service_name^}(Update${service_name^}Request) returns (Update${service_name^}Response) {
    option (google.api.http) = {
      put: "/v1/${service_name}s/{id}"
      body: "*"
    };
  }

  // Delete ${service_name}
  rpc Delete${service_name^}(Delete${service_name^}Request) returns (google.protobuf.Empty) {
    option (google.api.http) = {
      delete: "/v1/${service_name}s/{id}"
    };
  }

  // List ${service_name}s
  rpc List${service_name^}s(List${service_name^}sRequest) returns (List${service_name^}sResponse) {
    option (google.api.http) = {
      get: "/v1/${service_name}s"
    };
  }

  // Health check
  rpc Health(google.protobuf.Empty) returns (HealthResponse) {
    option (google.api.http) = {
      get: "/health"
    };
  }
}

// ${service_name^} entity
message ${service_name^} {
  string id = 1;
  string name = 2;
  string email = 3;
  google.protobuf.Timestamp created_at = 4;
  google.protobuf.Timestamp updated_at = 5;
}

// Create requests and responses
message Create${service_name^}Request {
  string name = 1;
  string email = 2;
}

message Create${service_name^}Response {
  ${service_name^} ${service_name} = 1;
}

// Get requests and responses
message Get${service_name^}Request {
  string id = 1;
}

message Get${service_name^}Response {
  ${service_name^} ${service_name} = 1;
}

// Update requests and responses
message Update${service_name^}Request {
  string id = 1;
  string name = 2;
  string email = 3;
}

message Update${service_name^}Response {
  ${service_name^} ${service_name} = 1;
}

// Delete requests and responses
message Delete${service_name^}Request {
  string id = 1;
}

// List requests and responses
message List${service_name^}sRequest {
  int32 page = 1;
  int32 page_size = 2;
}

message List${service_name^}sResponse {
  repeated ${service_name^} ${service_name}s = 1;
  int32 total = 2;
}

// Health response
message HealthResponse {
  string status = 1;
  google.protobuf.Timestamp timestamp = 2;
}
EOF
}

# Function to generate Buf configuration
generate_buf_config() {
    local output_dir="$1"
    local generate_buf="$2"
    
    if [[ "$generate_buf" == "false" ]]; then
        return
    fi
    
    echo -e "${BLUE}⚡ Generating Buf configuration...${NC}"
    
    # buf.yaml
    cat > "$output_dir/buf.yaml" << EOF
version: v1
name: buf.build/example/grpc-service
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
  except:
    - PACKAGE_DIRECTORY_MATCH
EOF
    
    # buf.gen.yaml
    cat > "$output_dir/buf.gen.yaml" << EOF
version: v1
plugins:
  - plugin: buf.build/protocolbuffers/go
    out: api/generated/go
    opt: paths=source_relative
  - plugin: buf.build/grpc/go
    out: api/generated/go
    opt:
      - paths=source_relative
      - require_unimplemented_servers=false
  - plugin: buf.build/grpc-ecosystem/grpc-gateway
    out: api/generated/go
    opt:
      - paths=source_relative
      - generate_unbound_methods=true
EOF
}

# Function to generate domain entities
generate_domain() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    
    echo -e "${BLUE}🏗️  Generating domain layer...${NC}"
    
    # Domain entity
    cat > "$output_dir/internal/core/domain/${service_name}.go" << EOF
package domain

import (
	"time"

	"github.com/google/uuid"
)

// ${service_name^} represents the core ${service_name} entity
type ${service_name^} struct {
	ID        string    \`json:"id"\`
	Name      string    \`json:"name"\`
	Email     string    \`json:"email"\`
	CreatedAt time.Time \`json:"created_at"\`
	UpdatedAt time.Time \`json:"updated_at"\`
}

// New${service_name^} creates a new ${service_name} with generated ID and timestamps
func New${service_name^}(name, email string) *${service_name^} {
	now := time.Now()
	return &${service_name^}{
		ID:        uuid.New().String(),
		Name:      name,
		Email:     email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// Update updates the ${service_name} fields and timestamp
func (u *${service_name^}) Update(name, email string) {
	if name != "" {
		u.Name = name
	}
	if email != "" {
		u.Email = email
	}
	u.UpdatedAt = time.Now()
}

// Validate validates the ${service_name} entity
func (u *${service_name^}) Validate() error {
	if u.Name == "" {
		return ErrInvalidName
	}
	if u.Email == "" {
		return ErrInvalidEmail
	}
	return nil
}
EOF

    # Domain errors
    cat > "$output_dir/internal/core/domain/errors.go" << EOF
package domain

import "errors"

var (
	// ${service_name^} errors
	Err${service_name^}NotFound = errors.New("${service_name} not found")
	Err${service_name^}AlreadyExists = errors.New("${service_name} already exists")
	ErrInvalidName = errors.New("invalid name")
	ErrInvalidEmail = errors.New("invalid email")
	
	// Generic errors
	ErrInternalServer = errors.New("internal server error")
	ErrInvalidInput = errors.New("invalid input")
)
EOF
}

# Function to generate ports (interfaces)
generate_ports() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    
    echo -e "${BLUE}🔌 Generating ports (interfaces)...${NC}"
    
    # Repository port
    cat > "$output_dir/internal/core/ports/repository.go" << EOF
package ports

import (
	"context"

	"$module_name/internal/core/domain"
)

// ${service_name^}Repository defines the interface for ${service_name} data operations
type ${service_name^}Repository interface {
	Create(ctx context.Context, ${service_name} *domain.${service_name^}) error
	GetByID(ctx context.Context, id string) (*domain.${service_name^}, error)
	GetByEmail(ctx context.Context, email string) (*domain.${service_name^}, error)
	Update(ctx context.Context, ${service_name} *domain.${service_name^}) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, page, pageSize int) ([]*domain.${service_name^}, int, error)
}
EOF

    # Service port
    cat > "$output_dir/internal/core/ports/service.go" << EOF
package ports

import (
	"context"

	"$module_name/internal/core/domain"
)

// ${service_name^}Service defines the business logic interface
type ${service_name^}Service interface {
	Create${service_name^}(ctx context.Context, name, email string) (*domain.${service_name^}, error)
	Get${service_name^}ByID(ctx context.Context, id string) (*domain.${service_name^}, error)
	Update${service_name^}(ctx context.Context, id, name, email string) (*domain.${service_name^}, error)
	Delete${service_name^}(ctx context.Context, id string) error
	List${service_name^}s(ctx context.Context, page, pageSize int) ([]*domain.${service_name^}, int, error)
}
EOF
}

# Function to generate core services
generate_core_services() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    
    echo -e "${BLUE}⚙️  Generating core services...${NC}"
    
    cat > "$output_dir/internal/core/services/${service_name}_service.go" << EOF
package services

import (
	"context"
	"strings"

	"go.uber.org/zap"

	"$module_name/internal/core/domain"
	"$module_name/internal/core/ports"
)

// ${service_name}Service implements the ${service_name} business logic
type ${service_name}Service struct {
	repo   ports.${service_name^}Repository
	logger *zap.Logger
}

// New${service_name^}Service creates a new ${service_name} service
func New${service_name^}Service(repo ports.${service_name^}Repository, logger *zap.Logger) ports.${service_name^}Service {
	return &${service_name}Service{
		repo:   repo,
		logger: logger,
	}
}

// Create${service_name^} creates a new ${service_name}
func (s *${service_name}Service) Create${service_name^}(ctx context.Context, name, email string) (*domain.${service_name^}, error) {
	s.logger.Info("Creating ${service_name}", zap.String("name", name), zap.String("email", email))

	// Validate input
	if strings.TrimSpace(name) == "" {
		return nil, domain.ErrInvalidName
	}
	if strings.TrimSpace(email) == "" {
		return nil, domain.ErrInvalidEmail
	}

	// Check if ${service_name} already exists
	existing, err := s.repo.GetByEmail(ctx, email)
	if err == nil && existing != nil {
		return nil, domain.Err${service_name^}AlreadyExists
	}

	// Create new ${service_name}
	${service_name} := domain.New${service_name^}(name, email)
	if err := ${service_name}.Validate(); err != nil {
		return nil, err
	}

	if err := s.repo.Create(ctx, ${service_name}); err != nil {
		s.logger.Error("Failed to create ${service_name}", zap.Error(err))
		return nil, domain.ErrInternalServer
	}

	s.logger.Info("${service_name^} created successfully", zap.String("id", ${service_name}.ID))
	return ${service_name}, nil
}

// Get${service_name^}ByID retrieves a ${service_name} by ID
func (s *${service_name}Service) Get${service_name^}ByID(ctx context.Context, id string) (*domain.${service_name^}, error) {
	s.logger.Info("Getting ${service_name} by ID", zap.String("id", id))

	if strings.TrimSpace(id) == "" {
		return nil, domain.ErrInvalidInput
	}

	${service_name}, err := s.repo.GetByID(ctx, id)
	if err != nil {
		s.logger.Error("Failed to get ${service_name}", zap.String("id", id), zap.Error(err))
		return nil, domain.Err${service_name^}NotFound
	}

	return ${service_name}, nil
}

// Update${service_name^} updates a ${service_name}
func (s *${service_name}Service) Update${service_name^}(ctx context.Context, id, name, email string) (*domain.${service_name^}, error) {
	s.logger.Info("Updating ${service_name}", zap.String("id", id))

	if strings.TrimSpace(id) == "" {
		return nil, domain.ErrInvalidInput
	}

	${service_name}, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, domain.Err${service_name^}NotFound
	}

	${service_name}.Update(name, email)
	if err := ${service_name}.Validate(); err != nil {
		return nil, err
	}

	if err := s.repo.Update(ctx, ${service_name}); err != nil {
		s.logger.Error("Failed to update ${service_name}", zap.Error(err))
		return nil, domain.ErrInternalServer
	}

	s.logger.Info("${service_name^} updated successfully", zap.String("id", id))
	return ${service_name}, nil
}

// Delete${service_name^} deletes a ${service_name}
func (s *${service_name}Service) Delete${service_name^}(ctx context.Context, id string) error {
	s.logger.Info("Deleting ${service_name}", zap.String("id", id))

	if strings.TrimSpace(id) == "" {
		return domain.ErrInvalidInput
	}

	if err := s.repo.Delete(ctx, id); err != nil {
		s.logger.Error("Failed to delete ${service_name}", zap.Error(err))
		return domain.ErrInternalServer
	}

	s.logger.Info("${service_name^} deleted successfully", zap.String("id", id))
	return nil
}

// List${service_name^}s lists ${service_name}s with pagination
func (s *${service_name}Service) List${service_name^}s(ctx context.Context, page, pageSize int) ([]*domain.${service_name^}, int, error) {
	s.logger.Info("Listing ${service_name}s", zap.Int("page", page), zap.Int("pageSize", pageSize))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 10
	}

	${service_name}s, total, err := s.repo.List(ctx, page, pageSize)
	if err != nil {
		s.logger.Error("Failed to list ${service_name}s", zap.Error(err))
		return nil, 0, domain.ErrInternalServer
	}

	return ${service_name}s, total, nil
}
EOF
}

# Function to generate gRPC server adapter
generate_grpc_server() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    
    echo -e "${BLUE}🌐 Generating gRPC server adapter...${NC}"
    
    cat > "$output_dir/internal/adapters/grpc/server/${service_name}_server.go" << EOF
package server

import (
	"context"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"$module_name/api/generated/go/${service_name}v1"
	"$module_name/internal/core/domain"
	"$module_name/internal/core/ports"
)

// ${service_name^}Server implements the gRPC ${service_name} server
type ${service_name^}Server struct {
	${service_name}v1.Unimplemented${service_name^}ServiceServer
	service ports.${service_name^}Service
}

// New${service_name^}Server creates a new gRPC ${service_name} server
func New${service_name^}Server(service ports.${service_name^}Service) *${service_name^}Server {
	return &${service_name^}Server{
		service: service,
	}
}

// Create${service_name^} handles the Create${service_name^} gRPC call
func (s *${service_name^}Server) Create${service_name^}(ctx context.Context, req *${service_name}v1.Create${service_name^}Request) (*${service_name}v1.Create${service_name^}Response, error) {
	${service_name}, err := s.service.Create${service_name^}(ctx, req.Name, req.Email)
	if err != nil {
		return nil, s.handleError(err)
	}

	return &${service_name}v1.Create${service_name^}Response{
		${service_name^}: s.domainToProto(${service_name}),
	}, nil
}

// Get${service_name^} handles the Get${service_name^} gRPC call
func (s *${service_name^}Server) Get${service_name^}(ctx context.Context, req *${service_name}v1.Get${service_name^}Request) (*${service_name}v1.Get${service_name^}Response, error) {
	${service_name}, err := s.service.Get${service_name^}ByID(ctx, req.Id)
	if err != nil {
		return nil, s.handleError(err)
	}

	return &${service_name}v1.Get${service_name^}Response{
		${service_name^}: s.domainToProto(${service_name}),
	}, nil
}

// Update${service_name^} handles the Update${service_name^} gRPC call
func (s *${service_name^}Server) Update${service_name^}(ctx context.Context, req *${service_name}v1.Update${service_name^}Request) (*${service_name}v1.Update${service_name^}Response, error) {
	${service_name}, err := s.service.Update${service_name^}(ctx, req.Id, req.Name, req.Email)
	if err != nil {
		return nil, s.handleError(err)
	}

	return &${service_name}v1.Update${service_name^}Response{
		${service_name^}: s.domainToProto(${service_name}),
	}, nil
}

// Delete${service_name^} handles the Delete${service_name^} gRPC call
func (s *${service_name^}Server) Delete${service_name^}(ctx context.Context, req *${service_name}v1.Delete${service_name^}Request) (*emptypb.Empty, error) {
	err := s.service.Delete${service_name^}(ctx, req.Id)
	if err != nil {
		return nil, s.handleError(err)
	}

	return &emptypb.Empty{}, nil
}

// List${service_name^}s handles the List${service_name^}s gRPC call
func (s *${service_name^}Server) List${service_name^}s(ctx context.Context, req *${service_name}v1.List${service_name^}sRequest) (*${service_name}v1.List${service_name^}sResponse, error) {
	${service_name}s, total, err := s.service.List${service_name^}s(ctx, int(req.Page), int(req.PageSize))
	if err != nil {
		return nil, s.handleError(err)
	}

	proto${service_name^}s := make([]*${service_name}v1.${service_name^}, len(${service_name}s))
	for i, ${service_name} := range ${service_name}s {
		proto${service_name^}s[i] = s.domainToProto(${service_name})
	}

	return &${service_name}v1.List${service_name^}sResponse{
		${service_name^}s: proto${service_name^}s,
		Total: int32(total),
	}, nil
}

// Health handles the health check gRPC call
func (s *${service_name^}Server) Health(ctx context.Context, req *emptypb.Empty) (*${service_name}v1.HealthResponse, error) {
	return &${service_name}v1.HealthResponse{
		Status:    "healthy",
		Timestamp: timestamppb.New(time.Now()),
	}, nil
}

// domainToProto converts domain ${service_name} to protobuf ${service_name}
func (s *${service_name^}Server) domainToProto(${service_name} *domain.${service_name^}) *${service_name}v1.${service_name^} {
	return &${service_name}v1.${service_name^}{
		Id:        ${service_name}.ID,
		Name:      ${service_name}.Name,
		Email:     ${service_name}.Email,
		CreatedAt: timestamppb.New(${service_name}.CreatedAt),
		UpdatedAt: timestamppb.New(${service_name}.UpdatedAt),
	}
}

// handleError converts domain errors to gRPC errors
func (s *${service_name^}Server) handleError(err error) error {
	switch err {
	case domain.Err${service_name^}NotFound:
		return status.Error(codes.NotFound, err.Error())
	case domain.Err${service_name^}AlreadyExists:
		return status.Error(codes.AlreadyExists, err.Error())
	case domain.ErrInvalidInput, domain.ErrInvalidName, domain.ErrInvalidEmail:
		return status.Error(codes.InvalidArgument, err.Error())
	default:
		return status.Error(codes.Internal, "internal server error")
	}
}
EOF
}

# Function to generate repository adapter
generate_repository() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    
    echo -e "${BLUE}🗄️  Generating repository adapter...${NC}"
    
    cat > "$output_dir/internal/adapters/repository/memory_${service_name}_repository.go" << EOF
package repository

import (
	"context"
	"sync"

	"$module_name/internal/core/domain"
	"$module_name/internal/core/ports"
)

// Memory${service_name^}Repository implements ${service_name} repository using in-memory storage
type Memory${service_name^}Repository struct {
	mu    sync.RWMutex
	${service_name}s map[string]*domain.${service_name^}
	emails map[string]string // email -> id mapping
}

// NewMemory${service_name^}Repository creates a new in-memory ${service_name} repository
func NewMemory${service_name^}Repository() ports.${service_name^}Repository {
	return &Memory${service_name^}Repository{
		${service_name}s: make(map[string]*domain.${service_name^}),
		emails: make(map[string]string),
	}
}

// Create stores a new ${service_name}
func (r *Memory${service_name^}Repository) Create(ctx context.Context, ${service_name} *domain.${service_name^}) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	// Check if email already exists
	if _, exists := r.emails[${service_name}.Email]; exists {
		return domain.Err${service_name^}AlreadyExists
	}

	r.${service_name}s[${service_name}.ID] = ${service_name}
	r.emails[${service_name}.Email] = ${service_name}.ID
	return nil
}

// GetByID retrieves a ${service_name} by ID
func (r *Memory${service_name^}Repository) GetByID(ctx context.Context, id string) (*domain.${service_name^}, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	${service_name}, exists := r.${service_name}s[id]
	if !exists {
		return nil, domain.Err${service_name^}NotFound
	}

	// Return a copy to avoid external modifications
	${service_name}Copy := *${service_name}
	return &${service_name}Copy, nil
}

// GetByEmail retrieves a ${service_name} by email
func (r *Memory${service_name^}Repository) GetByEmail(ctx context.Context, email string) (*domain.${service_name^}, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	id, exists := r.emails[email]
	if !exists {
		return nil, domain.Err${service_name^}NotFound
	}

	return r.GetByID(ctx, id)
}

// Update updates a ${service_name}
func (r *Memory${service_name^}Repository) Update(ctx context.Context, ${service_name} *domain.${service_name^}) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	existing, exists := r.${service_name}s[${service_name}.ID]
	if !exists {
		return domain.Err${service_name^}NotFound
	}

	// Update email mapping if email changed
	if existing.Email != ${service_name}.Email {
		delete(r.emails, existing.Email)
		r.emails[${service_name}.Email] = ${service_name}.ID
	}

	r.${service_name}s[${service_name}.ID] = ${service_name}
	return nil
}

// Delete removes a ${service_name}
func (r *Memory${service_name^}Repository) Delete(ctx context.Context, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	${service_name}, exists := r.${service_name}s[id]
	if !exists {
		return domain.Err${service_name^}NotFound
	}

	delete(r.${service_name}s, id)
	delete(r.emails, ${service_name}.Email)
	return nil
}

// List retrieves ${service_name}s with pagination
func (r *Memory${service_name^}Repository) List(ctx context.Context, page, pageSize int) ([]*domain.${service_name^}, int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	total := len(r.${service_name}s)
	if total == 0 {
		return []*domain.${service_name^}{}, 0, nil
	}

	// Convert map to slice
	all${service_name^}s := make([]*domain.${service_name^}, 0, total)
	for _, ${service_name} := range r.${service_name}s {
		${service_name}Copy := *${service_name}
		all${service_name^}s = append(all${service_name^}s, &${service_name}Copy)
	}

	// Apply pagination
	start := (page - 1) * pageSize
	if start >= total {
		return []*domain.${service_name^}{}, total, nil
	}

	end := start + pageSize
	if end > total {
		end = total
	}

	return all${service_name^}s[start:end], total, nil
}
EOF
}

# Function to generate configuration
generate_config() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    local port="$4"
    local grpc_port="$5"
    
    echo -e "${BLUE}⚙️  Generating configuration...${NC}"
    
    # Config struct
    cat > "$output_dir/internal/infrastructure/config/config.go" << EOF
package config

import (
	"github.com/spf13/viper"
)

// Config holds all configuration for the application
type Config struct {
	Server   ServerConfig   \`mapstructure:"server"\`
	GRPC     GRPCConfig     \`mapstructure:"grpc"\`
	Log      LogConfig      \`mapstructure:"log"\`
	Database DatabaseConfig \`mapstructure:"database"\`
}

// ServerConfig holds HTTP server configuration
type ServerConfig struct {
	Port         string \`mapstructure:"port"\`
	ReadTimeout  int    \`mapstructure:"read_timeout"\`
	WriteTimeout int    \`mapstructure:"write_timeout"\`
	IdleTimeout  int    \`mapstructure:"idle_timeout"\`
}

// GRPCConfig holds gRPC server configuration
type GRPCConfig struct {
	Port                string \`mapstructure:"port"\`
	MaxRecvMsgSize      int    \`mapstructure:"max_recv_msg_size"\`
	MaxSendMsgSize      int    \`mapstructure:"max_send_msg_size"\`
	ConnectionTimeout   int    \`mapstructure:"connection_timeout"\`
	MaxConnectionIdle   int    \`mapstructure:"max_connection_idle"\`
	MaxConnectionAge    int    \`mapstructure:"max_connection_age"\`
	MaxConnectionAgeGrace int  \`mapstructure:"max_connection_age_grace"\`
}

// LogConfig holds logging configuration
type LogConfig struct {
	Level      string \`mapstructure:"level"\`
	Format     string \`mapstructure:"format"\`
	OutputPath string \`mapstructure:"output_path"\`
}

// DatabaseConfig holds database configuration
type DatabaseConfig struct {
	Type string \`mapstructure:"type"\`
	DSN  string \`mapstructure:"dsn"\`
}

// Load loads configuration from file and environment variables
func Load(configPath string) (*Config, error) {
	config := &Config{
		Server: ServerConfig{
			Port:         "$port",
			ReadTimeout:  30,
			WriteTimeout: 30,
			IdleTimeout:  120,
		},
		GRPC: GRPCConfig{
			Port:                  "$grpc_port",
			MaxRecvMsgSize:        1024 * 1024 * 4, // 4MB
			MaxSendMsgSize:        1024 * 1024 * 4, // 4MB
			ConnectionTimeout:     120,
			MaxConnectionIdle:     300,
			MaxConnectionAge:      600,
			MaxConnectionAgeGrace: 30,
		},
		Log: LogConfig{
			Level:      "info",
			Format:     "json",
			OutputPath: "stdout",
		},
		Database: DatabaseConfig{
			Type: "memory",
			DSN:  "",
		},
	}

	if configPath != "" {
		viper.SetConfigFile(configPath)
		if err := viper.ReadInConfig(); err != nil {
			return nil, err
		}
		
		if err := viper.Unmarshal(config); err != nil {
			return nil, err
		}
	}

	// Override with environment variables
	viper.AutomaticEnv()
	viper.SetEnvPrefix("${service_name^^}")

	return config, nil
}
EOF

    # Configuration file
    cat > "$output_dir/configs/config.yaml" << EOF
server:
  port: "$port"
  read_timeout: 30
  write_timeout: 30
  idle_timeout: 120

grpc:
  port: "$grpc_port"
  max_recv_msg_size: 4194304  # 4MB
  max_send_msg_size: 4194304  # 4MB
  connection_timeout: 120
  max_connection_idle: 300
  max_connection_age: 600
  max_connection_age_grace: 30

log:
  level: "info"
  format: "json"
  output_path: "stdout"

database:
  type: "memory"
  dsn: ""
EOF
}

# Function to generate infrastructure components
generate_infrastructure() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    
    echo -e "${BLUE}🏗️  Generating infrastructure components...${NC}"
    
    # Logger
    cat > "$output_dir/internal/infrastructure/logger/logger.go" << EOF
package logger

import (
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"

	"$module_name/internal/infrastructure/config"
)

// New creates a new logger instance
func New(cfg config.LogConfig) (*zap.Logger, error) {
	var zapConfig zap.Config

	switch cfg.Level {
	case "debug":
		zapConfig = zap.NewDevelopmentConfig()
	default:
		zapConfig = zap.NewProductionConfig()
	}

	// Set log level
	level, err := zapcore.ParseLevel(cfg.Level)
	if err != nil {
		level = zapcore.InfoLevel
	}
	zapConfig.Level = zap.NewAtomicLevelAt(level)

	// Set output format
	if cfg.Format == "console" {
		zapConfig.Encoding = "console"
		zapConfig.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	}

	// Set output path
	if cfg.OutputPath != "" && cfg.OutputPath != "stdout" {
		zapConfig.OutputPaths = []string{cfg.OutputPath}
	}

	return zapConfig.Build()
}
EOF

    # gRPC Interceptors
    cat > "$output_dir/internal/infrastructure/interceptors/logging.go" << EOF
package interceptors

import (
	"context"
	"time"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// LoggingUnaryInterceptor logs gRPC unary requests
func LoggingUnaryInterceptor(logger *zap.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()

		resp, err := handler(ctx, req)

		duration := time.Since(start)
		code := codes.OK
		if err != nil {
			code = status.Code(err)
		}

		logger.Info("gRPC request",
			zap.String("method", info.FullMethod),
			zap.Duration("duration", duration),
			zap.String("code", code.String()),
			zap.Error(err),
		)

		return resp, err
	}
}

// LoggingStreamInterceptor logs gRPC stream requests
func LoggingStreamInterceptor(logger *zap.Logger) grpc.StreamServerInterceptor {
	return func(srv interface{}, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()

		err := handler(srv, stream)

		duration := time.Since(start)
		code := codes.OK
		if err != nil {
			code = status.Code(err)
		}

		logger.Info("gRPC stream",
			zap.String("method", info.FullMethod),
			zap.Duration("duration", duration),
			zap.String("code", code.String()),
			zap.Error(err),
		)

		return err
	}
}
EOF

    # Recovery interceptor
    cat > "$output_dir/internal/infrastructure/interceptors/recovery.go" << EOF
package interceptors

import (
	"context"
	"runtime/debug"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// RecoveryUnaryInterceptor recovers from panics in gRPC unary handlers
func RecoveryUnaryInterceptor(logger *zap.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (resp interface{}, err error) {
		defer func() {
			if r := recover(); r != nil {
				logger.Error("gRPC panic recovered",
					zap.String("method", info.FullMethod),
					zap.Any("panic", r),
					zap.String("stack", string(debug.Stack())),
				)
				err = status.Error(codes.Internal, "internal server error")
			}
		}()

		return handler(ctx, req)
	}
}

// RecoveryStreamInterceptor recovers from panics in gRPC stream handlers
func RecoveryStreamInterceptor(logger *zap.Logger) grpc.StreamServerInterceptor {
	return func(srv interface{}, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) (err error) {
		defer func() {
			if r := recover(); r != nil {
				logger.Error("gRPC stream panic recovered",
					zap.String("method", info.FullMethod),
					zap.Any("panic", r),
					zap.String("stack", string(debug.Stack())),
				)
				err = status.Error(codes.Internal, "internal server error")
			}
		}()

		return handler(srv, stream)
	}
}
EOF
}

# Function to generate HTTP adapter (Gin)
generate_http_adapter() {
    local output_dir="$1"
    local service_name="$2"
    local module_name="$3"
    local grpc_port="$4"
    
    echo -e "${BLUE}🌐 Generating HTTP adapter (Gin)...${NC}"
    
    cat > "$output_dir/internal/adapters/http/server.go" << EOF
package http

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	"$module_name/api/generated/go/${service_name}v1"
	"$module_name/internal/infrastructure/config"
)

// Server represents the HTTP server
type Server struct {
	router *gin.Engine
	logger *zap.Logger
	config *config.Config
}

// NewServer creates a new HTTP server
func NewServer(cfg *config.Config, logger *zap.Logger) *Server {
	gin.SetMode(gin.ReleaseMode)
	router := gin.New()

	// Add middleware
	router.Use(gin.Recovery())
	router.Use(corsMiddleware())
	router.Use(loggingMiddleware(logger))

	return &Server{
		router: router,
		logger: logger,
		config: cfg,
	}
}

// Setup sets up the HTTP routes and gRPC gateway
func (s *Server) Setup() error {
	// Health check endpoint
	s.router.GET("/health", s.healthHandler)

	// Setup gRPC gateway
	ctx := context.Background()
	mux := runtime.NewServeMux()

	opts := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())}
	err := ${service_name}v1.Register${service_name^}ServiceHandlerFromEndpoint(
		ctx,
		mux,
		"localhost:"+s.config.GRPC.Port,
		opts,
	)
	if err != nil {
		return err
	}

	// Mount gRPC gateway
	s.router.Any("/v1/*path", gin.WrapH(mux))

	return nil
}

// Start starts the HTTP server
func (s *Server) Start() error {
	s.logger.Info("Starting HTTP server", zap.String("port", s.config.Server.Port))
	return s.router.Run(":" + s.config.Server.Port)
}

// healthHandler handles health check requests
func (s *Server) healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "${service_name}-service",
	})
}

// corsMiddleware adds CORS headers
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

// loggingMiddleware logs HTTP requests
func loggingMiddleware(logger *zap.Logger) gin.HandlerFunc {
	return gin.CustomRecoveryWithWriter(nil, func(c *gin.Context, recovered interface{}) {
		logger.Error("HTTP panic recovered",
			zap.String("method", c.Request.Method),
			zap.String("path", c.Request.URL.Path),
			zap.Any("panic", recovered),
		)
		c.AbortWithStatus(http.StatusInternalServerError)
	})
}
EOF
}

# Function to generate main server application
generate_main_server() {
    local output_dir="$1"
    local module_name="$2"
    local service_name="$3"
    local port="$4"
    local grpc_port="$5"
    
    echo -e "${BLUE}🎯 Generating main server application...${NC}"
    
    cat > "$output_dir/cmd/server/main.go" << EOF
package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"go.uber.org/fx"
	"go.uber.org/zap"
	"google.golang.org/grpc"

	"$module_name/internal/adapters/grpc/server"
	"$module_name/internal/adapters/http"
	"$module_name/internal/adapters/repository"
	"$module_name/internal/core/services"
	"$module_name/internal/infrastructure/config"
	"$module_name/internal/infrastructure/logger"
)

func main() {
	app := fx.New(
		// Provide dependencies
		fx.Provide(
			config.New,
			logger.New,
			repository.New${service_name^}Repository,
			services.New${service_name^}Service,
			server.New${service_name^}Server,
			http.NewServer,
		),
		// Invoke application
		fx.Invoke(runApplication),
	)

	app.Run()
}

func runApplication(
	cfg *config.Config,
	logger *zap.Logger,
	grpcServer *server.${service_name^}Server,
	httpServer *http.Server,
) {
	// Start gRPC server
	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", cfg.GRPCPort))
	if err != nil {
		logger.Fatal("Failed to listen on gRPC port", zap.Error(err))
	}

	s := grpc.NewServer()
	grpcServer.Register(s)

	go func() {
		logger.Info("Starting gRPC server", zap.String("port", cfg.GRPCPort))
		if err := s.Serve(lis); err != nil {
			logger.Fatal("Failed to serve gRPC", zap.Error(err))
		}
	}()

	// Start HTTP server
	go func() {
		logger.Info("Starting HTTP server", zap.String("port", cfg.Port))
		if err := httpServer.Start(cfg.Port); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Failed to start HTTP server", zap.Error(err))
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Shutting down servers...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(ctx); err != nil {
		logger.Error("HTTP server forced to shutdown", zap.Error(err))
	}

	s.GracefulStop()
	logger.Info("Servers stopped")
}
EOF
}

# Function to generate Docker files
generate_docker_files() {
    local output_dir="$1"
    local service_name="$2"
    local port="$3"
    local grpc_port="$4"
    local generate_docker="$5"
    
    if [[ "$generate_docker" == "false" ]]; then
        return
    fi
    
    echo -e "${BLUE}🐳 Generating Docker files...${NC}"
    
    # Dockerfile
    cat > "$output_dir/Dockerfile" << EOF
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/server

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/configs ./configs

# Expose ports
EXPOSE $port $grpc_port

CMD ["./main"]
EOF

    # Docker Compose
    cat > "$output_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  ${service_name}:
    build: .
    ports:
      - "$port:$port"
      - "$grpc_port:$grpc_port"
    environment:
      - APP_ENV=development
      - LOG_LEVEL=debug
    volumes:
      - ./configs:/app/configs
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${service_name}_db
      POSTGRES_USER: ${service_name}_user
      POSTGRES_PASSWORD: ${service_name}_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
EOF

    # .dockerignore
    cat > "$output_dir/.dockerignore" << EOF
.git
.gitignore
README.md
Dockerfile
docker-compose.yml
.dockerignore
.env
.env.local
node_modules
coverage
.nyc_output
test
docs
*.md
EOF
}

# Function to generate Makefile
generate_makefile() {
    local output_dir="$1"
    local service_name="$2"
    local generate_makefile="$3"
    
    if [[ "$generate_makefile" == "false" ]]; then
        return
    fi
    
    echo -e "${BLUE}⚙️  Generating Makefile...${NC}"
    
    cat > "$output_dir/Makefile" << EOF
.PHONY: help build run test clean proto docker

# Default target
help: ## Show this help
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' \$(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", \$\$1, \$\$2}'

# Go commands
build: ## Build the application
	go build -o bin/server ./cmd/server

run: ## Run the application
	go run ./cmd/server

test: ## Run tests
	go test -v ./...

test-coverage: ## Run tests with coverage
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

clean: ## Clean build artifacts
	rm -rf bin/
	rm -f coverage.out coverage.html

# Dependencies
deps: ## Install dependencies
	go mod download
	go mod tidy

# Protocol Buffers
proto: ## Generate protobuf files
	buf generate

proto-lint: ## Lint protobuf files
	buf lint

proto-breaking: ## Check for breaking changes
	buf breaking --against '.git#branch=main'

# Docker commands
docker-build: ## Build Docker image
	docker build -t ${service_name}:latest .

docker-run: ## Run Docker container
	docker-compose up -d

docker-stop: ## Stop Docker containers
	docker-compose down

docker-logs: ## Show Docker logs
	docker-compose logs -f

# Development
dev: ## Run in development mode with hot reload
	air

format: ## Format code
	go fmt ./...
	goimports -w .

lint: ## Run linter
	golangci-lint run

# Database
migrate-up: ## Run database migrations
	migrate -path ./migrations -database "postgres://localhost/\${service_name}_db?sslmode=disable" up

migrate-down: ## Rollback database migrations
	migrate -path ./migrations -database "postgres://localhost/\${service_name}_db?sslmode=disable" down

# Kubernetes
k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f deployments/k8s/

k8s-delete: ## Delete from Kubernetes
	kubectl delete -f deployments/k8s/

# Tools
install-tools: ## Install development tools
	go install github.com/air-verse/air@latest
	go install github.com/bufbuild/buf/cmd/buf@latest
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
EOF
}

# Function to generate additional configuration files
generate_additional_files() {
    local output_dir="$1"
    local service_name="$2"
    
    echo -e "${BLUE}📄 Generating additional configuration files...${NC}"
    
    # .gitignore
    cat > "$output_dir/.gitignore" << EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib
bin/
*.test
*.out

# Go workspace file
go.work

# Environment files
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Coverage reports
coverage.out
coverage.html

# Docker
.dockerignore

# Logs
*.log

# Dependencies
vendor/

# Generated files
api/generated/
EOF

    # README.md
    cat > "$output_dir/README.md" << EOF
# ${service_name^} Service

A modern Go gRPC service built with hexagonal architecture.

## Features

- 🏗️ **Hexagonal Architecture** - Clean separation of concerns
- 🚀 **gRPC & HTTP Gateway** - Dual protocol support
- 📊 **Structured Logging** - Zap logger integration
- 🐳 **Docker Ready** - Containerized deployment
- 🧪 **Testing** - Unit and integration tests
- 📦 **Protocol Buffers** - Type-safe API definitions
- ⚡ **Hot Reload** - Development with Air
- 🔧 **Makefile** - Common development tasks

## Quick Start

### Prerequisites

- Go 1.21+
- Docker & Docker Compose
- Buf CLI (for Protocol Buffers)

### Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   make deps
   \`\`\`

3. Generate Protocol Buffer files:
   \`\`\`bash
   make proto
   \`\`\`

4. Run the service:
   \`\`\`bash
   make run
   \`\`\`

### Using Docker

\`\`\`bash
make docker-run
\`\`\`

## API Documentation

### gRPC Endpoints

- \`Create${service_name^}\` - Create a new ${service_name}
- \`Get${service_name^}\` - Get ${service_name} by ID
- \`Update${service_name^}\` - Update ${service_name}
- \`Delete${service_name^}\` - Delete ${service_name}
- \`List${service_name^}s\` - List ${service_name}s with pagination

### HTTP Endpoints

- \`POST /v1/${service_name}s\` - Create ${service_name}
- \`GET /v1/${service_name}s/{id}\` - Get ${service_name}
- \`PUT /v1/${service_name}s/{id}\` - Update ${service_name}
- \`DELETE /v1/${service_name}s/{id}\` - Delete ${service_name}
- \`GET /v1/${service_name}s\` - List ${service_name}s
- \`GET /health\` - Health check

## Development

### Running Tests

\`\`\`bash
make test
\`\`\`

### Code Coverage

\`\`\`bash
make test-coverage
\`\`\`

### Linting

\`\`\`bash
make lint
\`\`\`

### Hot Reload

\`\`\`bash
make dev
\`\`\`

## Project Structure

\`\`\`
.
├── api/
│   ├── proto/              # Protocol Buffer definitions
│   └── generated/          # Generated code
├── cmd/
│   └── server/             # Application entrypoint
├── internal/
│   ├── core/
│   │   ├── domain/         # Business entities
│   │   ├── ports/          # Interfaces
│   │   └── services/       # Business logic
│   ├── adapters/
│   │   ├── grpc/           # gRPC adapters
│   │   ├── http/           # HTTP adapters
│   │   └── repository/     # Data persistence
│   └── infrastructure/     # Cross-cutting concerns
├── configs/                # Configuration files
├── deployments/            # Deployment configurations
├── docs/                   # Documentation
├── scripts/                # Utility scripts
└── test/                   # Test files
\`\`\`

## License

MIT License
EOF

    # Air configuration for hot reload
    cat > "$output_dir/.air.toml" << EOF
root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/server"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata", "api/generated"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html"]
  kill_delay = "0s"
  log = "build-errors.log"
  send_interrupt = false
  stop_on_root = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
  keep_scroll = true
EOF
}

# Function to parse command line arguments
parse_arguments() {
    local output_dir=""
    local module_name="$DEFAULT_MODULE_NAME"
    local service_name="$DEFAULT_SERVICE_NAME"
    local go_version="$DEFAULT_GO_VERSION"
    local port="$DEFAULT_PORT"
    local grpc_port="$DEFAULT_GRPC_PORT"
    local generate_docker="true"
    local generate_makefile="true"
    local generate_buf="true"
    local verbose="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --out=*)
                output_dir="${1#*=}"
                shift
                ;;
            --module=*)
                module_name="${1#*=}"
                shift
                ;;
            --service=*)
                service_name="${1#*=}"
                shift
                ;;
            --go-version=*)
                go_version="${1#*=}"
                shift
                ;;
            --port=*)
                port="${1#*=}"
                shift
                ;;
            --grpc-port=*)
                grpc_port="${1#*=}"
                shift
                ;;
            --no-docker)
                generate_docker="false"
                shift
                ;;
            --no-makefile)
                generate_makefile="false"
                shift
                ;;
            --no-buf)
                generate_buf="false"
                shift
                ;;
            --verbose)
                verbose="true"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown argument: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$output_dir" ]]; then
        echo -e "${RED}❌ Output directory is required. Use --out=<path>${NC}"
        show_help
        exit 1
    fi
    
    # Export variables for use in other functions
    export OUTPUT_DIR="$output_dir"
    export MODULE_NAME="$module_name"
    export SERVICE_NAME="$service_name"
    export GO_VERSION="$go_version"
    export PORT="$port"
    export GRPC_PORT="$grpc_port"
    export GENERATE_DOCKER="$generate_docker"
    export GENERATE_MAKEFILE="$generate_makefile"
    export GENERATE_BUF="$generate_buf"
    export VERBOSE="$verbose"
}

# Main function to orchestrate the generation
main() {
    echo -e "${BLUE}🚀 Go gRPC Project Generator${NC}"
    echo -e "${BLUE}===============================${NC}"
    
    # Parse arguments
    parse_arguments "$@"
    
    # Validate requirements
    validate_requirements
    
    # Check if output directory exists
    if [[ -d "$OUTPUT_DIR" ]] && [[ "$(ls -A "$OUTPUT_DIR")" ]]; then
        echo -e "${YELLOW}⚠️  Output directory is not empty: $OUTPUT_DIR${NC}"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}❌ Aborted${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}📋 Configuration:${NC}"
    echo -e "  Output Directory: ${CYAN}$OUTPUT_DIR${NC}"
    echo -e "  Module Name: ${CYAN}$MODULE_NAME${NC}"
    echo -e "  Service Name: ${CYAN}$SERVICE_NAME${NC}"
    echo -e "  Go Version: ${CYAN}$GO_VERSION${NC}"
    echo -e "  HTTP Port: ${CYAN}$PORT${NC}"
    echo -e "  gRPC Port: ${CYAN}$GRPC_PORT${NC}"
    echo -e "  Generate Docker: ${CYAN}$GENERATE_DOCKER${NC}"
    echo -e "  Generate Makefile: ${CYAN}$GENERATE_MAKEFILE${NC}"
    echo -e "  Generate Buf Config: ${CYAN}$GENERATE_BUF${NC}"
    echo ""
    
    # Generate project
    create_directory_structure "$OUTPUT_DIR"
    generate_go_mod "$OUTPUT_DIR" "$MODULE_NAME" "$GO_VERSION"
    generate_proto_files "$OUTPUT_DIR" "$SERVICE_NAME"
    generate_buf_config "$OUTPUT_DIR" "$GENERATE_BUF"
    generate_domain "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME"
    generate_ports "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME"
    generate_core_services "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME"
    generate_grpc_server "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME"
    generate_repository "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME"
    generate_config "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME" "$PORT" "$GRPC_PORT"
    generate_infrastructure "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME"
    generate_http_adapter "$OUTPUT_DIR" "$SERVICE_NAME" "$MODULE_NAME" "$GRPC_PORT"
    generate_main_server "$OUTPUT_DIR" "$MODULE_NAME" "$SERVICE_NAME" "$PORT" "$GRPC_PORT"
    generate_docker_files "$OUTPUT_DIR" "$SERVICE_NAME" "$PORT" "$GRPC_PORT" "$GENERATE_DOCKER"
    generate_makefile "$OUTPUT_DIR" "$SERVICE_NAME" "$GENERATE_MAKEFILE"
    generate_additional_files "$OUTPUT_DIR" "$SERVICE_NAME"
    
    echo ""
    echo -e "${GREEN}🎉 Project generated successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. ${CYAN}cd $OUTPUT_DIR${NC}"
    echo -e "  2. ${CYAN}make deps${NC}               # Install dependencies"
    echo -e "  3. ${CYAN}make proto${NC}              # Generate protobuf files"
    echo -e "  4. ${CYAN}make run${NC}                # Run the service"
    echo ""
    echo -e "${YELLOW}Development commands:${NC}"
    echo -e "  • ${CYAN}make help${NC}               # Show all available commands"
    echo -e "  • ${CYAN}make dev${NC}                # Run with hot reload"
    echo -e "  • ${CYAN}make test${NC}               # Run tests"
    echo -e "  • ${CYAN}make docker-run${NC}         # Run with Docker"
    echo ""
    echo -e "${BLUE}Happy coding! 🚀${NC}"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
